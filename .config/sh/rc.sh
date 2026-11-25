: "${XDG_CONFIG_HOME:="$HOME/.config"}"

. "$XDG_CONFIG_HOME/sh/lib/core.sh"

# what only one OS has: rc.d/openbsd.sh, rc.d/linux.sh, rc.d/darwin.sh
_os=$(uname | tr '[:upper:]' '[:lower:]')
[ -f "$XDG_CONFIG_HOME/sh/rc.d/$_os.sh" ] && . "$XDG_CONFIG_HOME/sh/rc.d/$_os.sh"
unset _os

if have doas; then DOAS='doas'; else DOAS='sudo'; fi

# root through doas/sudo/su: the invoking user's ~/.local/bin, after the system's
if [ "$(id -u)" -eq 0 ]; then
    # su leaves no other trace of who ran it: logname is just $LOGNAME on musl,
    # and su sets that to root. The terminal is still owned by them
    _ru="${DOAS_USER:-${SUDO_USER:-}}"
    [ -n "$_ru" ] || _ru=$(ls -ld "$(tty 2>/dev/null)" 2>/dev/null | awk '{ print $3 }')
    case "$_ru" in
        ''|root|*[!A-Za-z0-9._-]*) : ;;
        *)  eval "_rd=~$_ru/.local/bin"
            case ":$PATH:" in
                *":$_rd:"*) : ;;
                *) [ -d "$_rd" ] && PATH="$PATH:$_rd" && export PATH ;;
            esac ;;
    esac
    unset _ru _rd
fi

# command: zsh's sh emulation refuses the option, and a failing special builtin
# would end rc.sh there
command set -o vi 2>/dev/null
# ksh-family shells keep no history file unless HISTFILE is set
: "${HISTFILE:=$HOME/.sh_history}" "${HISTSIZE:=10000}"
ulimit -c 0 2>/dev/null

[ -n "${INITIAL_FOLDER:-}" ] && cd "$INITIAL_FOLDER"

# eza is the normal case, but ls has to work: on a fresh install rc.sh loads
# before any package exists, and a bare `c` is its last line
_c_ls() {
    clear 2>/dev/null
    if have eza; then
        eza -lh "$@" --group-directories-first --no-quotes --icons always --color always
    else
        ls -lh "$@"
    fi
}

# the one command for moving around and opening things. Every directory
# reached through it is added to zoxide, which replaces the `zoxide init` hook:
#   c              list the current directory
#   c <dir>        cd
#   c <file>…      openfile
#   c <query>      zoxide jump: a single match goes straight there, several
#                  open the picker
# ca, or c -a, does the same and lists hidden files too. Every directory c
# leaves goes on _c_stack, one per line and newest last, for b to walk back
# through. It is a plain variable, so each shell keeps its own
_c_nl='
'
c() {
    _c_all=
    [ "$1" = -a ] && { _c_all=1; shift; }
    [ -n "$1" ] || { _c_ls ${_c_all:+-a}; unset _c_all; return; }
    _c_start="$(pwd)"

    if [ -f "$1" ]; then
        openfile "$@"
    elif [ -d "$1" ]; then
        cd "$1" || { unset _c_start _c_all; return; }
    # query -l sai 0 com stdout vazio quando não há match
    elif have zoxide && _c_hits="$(zoxide query -l -- "$1" 2>/dev/null)" && [ -n "$_c_hits" ]; then
        if [ "$(printf '%s\n' "$_c_hits" | wc -l | tr -d '[:space:]')" = 1 ]; then
            _c_hit="$_c_hits"
        else
            _c_hit="$(zoxide query -i -- "$1" 2>/dev/null)"
        fi
        [ -n "$_c_hit" ] && cd "$_c_hit"
    else
        printf 'c: %s: no match\n' "$1" >&2
    fi

    if [ "$_c_start" != "$(pwd)" ]; then
        _c_stack="${_c_stack-}$_c_start$_c_nl"
        have zoxide && zoxide add -- "$(pwd)"
        _c_ls ${_c_all:+-a}
    fi
    unset _c_start _c_hits _c_hit _c_all
}

ca() { c -a "$@"; }

# back to the last directory c left. Ones that are gone, or the one you are
# in, are dropped on the way; going back pushes nothing
b() {
    while [ -n "${_c_stack-}" ]; do
        _b_dir="${_c_stack%"$_c_nl"}"
        _b_dir="${_b_dir##*"$_c_nl"}"
        _c_stack="${_c_stack%"$_b_dir$_c_nl"}"
        if [ -d "$_b_dir" ] && [ "$_b_dir" != "$(pwd)" ]; then
            _b_rest="$_c_stack"
            c "$_b_dir"
            _c_stack="$_b_rest"
            unset _b_dir _b_rest
            return
        fi
    done
    unset _b_dir
    printf 'b: no directory to go back to\n' >&2
    return 1
}

# without fzf: the numbered matches, for fc or r
hist() {
    if ! have fzf; then fc -l 1 | grep -F -- "${1:-}"; return 0; fi
    _h="$(fc -ln 1 2>/dev/null | sed 's/^[[:space:]]*//' | awk 'NF && !seen[$0]++' \
        | fzf --tac --no-sort --query="${1:-}" --prompt='hist> ' \
              --height=40% --reverse --expect=ctrl-e)" || return 0
    _k="$(printf '%s\n' "$_h" | sed -n 1p)"
    _c="$(printf '%s\n' "$_h" | sed -n '2,$p')"
    [ -n "$_c" ] || return 0
    if [ "$_k" = ctrl-e ]; then
        _t="$(mktemp)"; printf '%s\n' "$_c" > "$_t"
        "${EDITOR:-vi}" "$_t"; _c="$(cat "$_t")"; rm -f "$_t"
    fi
    eval "$_c"
    unset _h _k _c _t
}

see() { tee /dev/tty; }

# make doctor asks a new interactive shell for this: an answer means ENV works
rc_loaded() { printf 'rc.sh loaded by %s\n' "${0##*[-/]}"; }

p() { [ -s "$CLIPFILE" ] || return; while IFS= read -r _e; do cp -Rv -- "$_e" .; done < "$CLIPFILE"; unset _e; }
m() { [ -s "$CLIPFILE" ] || return; while IFS= read -r _e; do mv -v -- "$_e" .; done < "$CLIPFILE"; : > "$CLIPFILE"; unset _e; }

# the one picker: alone it fills $CLIPFILE for p and m; with arguments, the
# first is a command run with the selection appended
sel() {
    have fzf || { printf 'sel: needs fzf\n' >&2; return 1; }

    if [ -n "$1" ]; then _sel_cmd="$1"; shift; else _sel_cmd=""; fi
    # eza's lines start with an icon and a space, cut before use
    if have eza; then
        _sel_ls='eza -1 --group-directories-first --no-quotes --icons always --color always'
        _sel_all="$_sel_ls -a" _sel_pv='p={}; preview "${p#* }"'
    else
        _sel_ls='ls -1' _sel_all='ls -1A' _sel_pv='preview {}'
    fi

    _sel_out="$($_sel_ls | fzf \
        --ansi \
        --multi \
        --prompt="$(pwd)/" \
        --bind 'tab:toggle+clear-query+down' \
        --bind 'shift-tab:toggle+clear-query+up' \
        --bind 'ctrl-t:toggle-all' \
        --bind 'ctrl-e:deselect-all' \
        --bind 'alt-j:jump,jump:toggle' \
        --bind 'alt-g:first' \
        --bind 'alt-G:last' \
        --bind "alt-h:reload($_sel_all)" \
        --bind "alt-H:reload($_sel_ls)" \
        --bind 'ctrl-l:accept' \
        --height 100% \
        --color=bg+:-1 \
        --border=sharp \
        --info=inline \
        --reverse \
        --preview "$_sel_pv")" || return
    [ -n "$_sel_out" ] || return 1

    while IFS= read -r _sel_l; do
        have eza && _sel_l=${_sel_l#* }
        abspath "$_sel_l"
    done > "$CLIPFILE" <<EOF
$_sel_out
EOF

    unset _sel_ls _sel_all _sel_pv _sel_out _sel_l
    [ -n "$_sel_cmd" ] || { unset _sel_cmd; return 0; }
    while IFS= read -r _sel_e; do set -- "$@" "$_sel_e"; done < "$CLIPFILE"
    set -- "$_sel_cmd" "$@"
    unset _sel_cmd _sel_e
    "$@"
}

# -c makes the command fifo nvim opens panes through. DVTM_OUTER_TERM, set per
# machine, names an outer terminfo with RGB, which gets 24-bit colour out of
# ncurses; passed through env, so this shell never has to read it
have dvtm && dvtm() {
    if [ -n "$DVTM_OUTER_TERM" ]; then
        env TERM="$DVTM_OUTER_TERM" dvtm -c "${TMPDIR:-/tmp}/dvtm.$$.cmd" "$@"
    else
        command dvtm -c "${TMPDIR:-/tmp}/dvtm.$$.cmd" "$@"
    fi
}

f() {
    if have fd; then fd "$1"; elif have fdfind; then fdfind "$1"; else find . -iname "*$1*"; fi
}
g() { grep -nRIi -- "$1" .; }

# the file helpers below run in ( ): exit, traps and variables stay inside

# the freedesktop trash, the one gio and file managers use: ~/.local/share/Trash
# for files on /home, a .Trash-$UID at the top of other filesystems. Each item
# keeps its original path; gio trash --list shows them, --restore puts one back
trash() (
    [ "$#" -gt 0 ] || exit 0
    gio trash -- "$@"
)
shredtrash() (
    clear 2>/dev/null
    printf '\nempty the trash (%s items)? [y/N] ' "$(gio trash --list | wc -l | tr -d ' ')"
    read -r ans && case $ans in [yY]) gio trash --empty ;; esac
)
d() (
    [ "$#" -gt 0 ] || exit 0
    clear 2>/dev/null
    printf '\n\t%s' "$@"
    printf '\n\ndelete? [y/N] '
    read -r ans && case $ans in [yY]) rm -rf -- "$@" ;; esac
)

# the names in this folder, one per line, edited in $EDITOR
bulkrename() (
    old=$(mktemp) && new=$(mktemp) || exit 1
    trap 'rm -f "$old" "$new"' EXIT
    ls > "$old"
    cp -- "$old" "$new"
    "${EDITOR:-vi}" "$new"
    [ "$(wc -l < "$old")" -eq "$(wc -l < "$new")" ] ||
        { echo "bulkrename: line count changed, aborting" >&2; exit 1; }
    paste "$old" "$new" | {
        while IFS="$(printf '\t')" read -r src dst; do
            [ "$src" != "$dst" ] || continue
            if [ -e "$dst" ] || [ -L "$dst" ]; then
                echo "bulkrename: $dst exists, $src left as is" >&2; r=1
            else
                mv -- "$src" "$dst" || r=1
            fi
        done
        exit "${r:-0}"
    }
)

# shadows POSIX compress(1) at the prompt
compress() (
    out=$1; shift
    case $out in
        *.tar.bz2|*.tbz2) tar cjvf "$out" "$@" ;;
        *.tar.gz|*.tgz)   tar czvf "$out" "$@" ;;
        *.tar.xz|*.txz)   tar cvf - "$@" | xz > "$out" ;;
        *.tar)            tar cvf  "$out" "$@" ;;
        *.zip)            zip -r "$out" "$@" ;;
        *.rar)            rar a "$out" "$@" ;;
        *.7z)             7z a "$out" "$@" ;;
        *) echo "compress: unknown archive type: $out" >&2; exit 1 ;;
    esac
)
extract() (
    case $1 in
        *.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar xjvf "$1" ;;
        *.tar.gz|*.tgz)                  tar xzvf "$1" ;;
        *.tar.xz|*.txz)                  xz -dc "$1" | tar xvf - ;;
        *.tar)                           tar xvf  "$1" ;;
        *.zip)                           unzip "$1" ;;
        *.rar)                           unrar x "$1" ;;
        *.7z)                            7z x "$1" ;;
        *.gz)                            gunzip "$1" ;;
        *.bz2)                           bunzip2 "$1" ;;
        *) echo "extract: unknown archive type: $1" >&2; exit 1 ;;
    esac
)

alias doas="${DOAS} "
alias s="sel"
alias sc="sel c"
alias sca="sel ca"
alias t="trash"
alias u="c .."

gcm() { git checkout "$(git get-default-branch)"; }
gpom() { _b="$(git get-default-branch)"; git pull origin "$_b"; unset _b; }
newb() { _b="$(git get-default-branch)"; git checkout "$_b" && git pull origin "$_b" && git checkout -b "$1"; unset _b; }


have sixiv && alias img="sixiv -t"
have mpv && alias play="mpv --shuffle ."

# the prompt's escapes per shell, from rc.d/<shell>.sh: _cwd for the folder,
# _m1 _m2 around the colour codes
if [ -n "${ZSH_VERSION:-}" ]; then _sh=zsh
elif [ -n "${BASH_VERSION:-}" ]; then _sh=bash
elif [ -n "${KSH_VERSION:-}" ]; then _sh=ksh
else _sh=sh; fi
_cwd='${PWD}' _m1='' _m2=''
[ -f "$XDG_CONFIG_HOME/sh/rc.d/$_sh.sh" ] && . "$XDG_CONFIG_HOME/sh/rc.d/$_sh.sh"
if [ -n "${SSH_CONNECTION:-}" ]; then
    _pid="[${USER:-$(id -un)}@$(hostname 2>/dev/null | cut -d. -f1)] "
else
    _pid=""
fi
if [ "$(id -u)" -eq 0 ]; then
    PS1="${_m1}$(printf '\033[31m')${_m2}${_pid}[${_cwd}] \$ ${_m1}$(printf '\033[0m')${_m2}"
else
    PS1="${_pid}[${_cwd}] \$ "
fi
export PS1
unset _m1 _m2 _pid _cwd _sh

c
