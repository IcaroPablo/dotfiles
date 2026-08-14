: "${XDG_CONFIG_HOME:="$HOME/.config"}"

[ -f "$XDG_CONFIG_HOME/sh/lib/guard.sh" ] && . "$XDG_CONFIG_HOME/sh/lib/guard.sh"
command -v have >/dev/null 2>&1 || have() { command -v "$1" >/dev/null 2>&1; }

if have doas; then DOAS='doas'; else DOAS='sudo'; fi

set -o vi 2>/dev/null || true
ulimit -c 0 2>/dev/null || true

[ -n "${INITIAL_FOLDER:-}" ] && cd "$INITIAL_FOLDER"

if have zoxide; then
    eval "$(zoxide init posix --cmd z 2>/dev/null)" 2>/dev/null || true
fi

e() {
    clear 2>/dev/null || true
    if have eza; then
        eza -lh "$@" --group-directories-first --no-quotes --icons always --color always
    else
        ls -lhA "$@"
    fi
}

c() {
    _c_start="$(pwd)"

    if [ -n "$1" ]; then
        if [ ! -e "$1" ] && have "$1"; then
            interactive-select || { unset _c_start; return; }
            [ -s "$CLIPFILE" ] && xargs -0 "$@" < "$CLIPFILE"
            unset _c_start; return
        fi
        if [ -f "$1" ]; then
            openfile "$@"
            unset _c_start; return
        fi
        if [ -d "$1" ]; then
            cd "$1" || { unset _c_start; return; }
        elif have zi; then
            zi "$1"
        fi
        [ "$_c_start" = "$(pwd)" ] && { unset _c_start; return; }
    fi

    while :; do
        # interactive-select || break
        [ -s "$CLIPFILE" ] || break
        _c_n="$(tr -cd '\0' < "$CLIPFILE" | wc -c | tr -d '[:space:]')"
        if [ "$_c_n" = 1 ]; then
            _c_entry="$(tr -d '\0' < "$CLIPFILE")"
            [ -d "$_c_entry" ] && { cd "$_c_entry" && continue; }
        fi
        xargs -0 openfile < "$CLIPFILE"
        break
    done

    [ "$_c_start" != "$(pwd)" ] && e
    unset _c_start _c_n _c_entry
}

hist() {
    if have fzf; then
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
    else
        case "$1" in
            -)  shift
                fc -l 1 | grep -F -- "$1" || return 0
                printf 'number (prefix with e to edit): '
                read -r _n || return 0
                case "$_n" in
                    "") : ;;
                    e*) fc "${_n#e}" ;;
                    *)  _c="$(fc -ln "$_n" "$_n" 2>/dev/null)"; [ -n "$_c" ] && eval "$_c" ;;
                esac
                unset _n _c ;;
            *)  fc -ln 1 | grep -F -- "$1" || return 0 ;;
        esac
    fi
}

see() { tee /dev/tty; }

p() { [ -s "$CLIPFILE" ] && xargs -0 -I{} cp -Rv -- {} . < "$CLIPFILE"; }
m() { [ -s "$CLIPFILE" ] && xargs -0 -I{} mv -v -- {} . < "$CLIPFILE" && : > "$CLIPFILE"; }

alias a="create"
alias doas="${DOAS} "
alias ea="e -a"
alias f="findfile"
alias g="simplegrep"
alias nvim="launch_nvim"
alias rm="rm -i"
alias s="interactive-select"
alias sa="interactive-select --show-hidden"
alias so="c openfile"
alias ss="split_scr"
alias t="trash"
alias u="cd .. && e"

_gbranch() {
    _b="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
    _b="${_b#origin/}"
    if [ -z "$_b" ]; then
        for _c in main master; do
            git show-ref --verify --quiet "refs/remotes/origin/$_c" && { _b="$_c"; break; }
        done
    fi
    printf '%s\n' "${_b:-main}"
}
gcm() { git checkout "$(_gbranch)"; }
gpom() { _b="$(_gbranch)"; git pull origin "$_b"; unset _b; }
newb() { _b="$(_gbranch)"; git checkout "$_b" && git pull origin "$_b" && git checkout -b "$1"; unset _b; }

case "$(uname)" in
    OpenBSD)
        [ -n "${KSH_VERSION:-}" ] && [ -f /etc/ksh.kshrc ] && . /etc/ksh.kshrc

        req() {
            _in=0
            printf "%s" "$(pkg_info "$1")" | while IFS= read -r _line; do
                if [ "$_in" = 0 ] && [ "$_line" = "Required by:" ]; then _in=1; continue; fi
                [ "$_in" = 1 ] && [ "$_line" = "" ] && _in=0
                [ "$_in" = 1 ] && printf '%s\n' "$_line"
            done
        }
        req_by() { pkg_info -f "$1" | grep '^@depend' | cut -f 3 -d :; }
        get_orphans() {
            for _p in $(pkg_info -mz); do
                _p="${_p%--}"
                [ -z "$(req "$_p")" ] && printf '%s\n' "$_p"
            done
        }
        del() { doas pkg_delete "$1" && doas pkg_delete -a; }
        alias add="doas pkg_add -Dsnap"
        have ntpctl && alias chkclock="ntpctl -s all"
        have systat && alias sensors="systat -s 1 sensors"
        ;;
    Linux)
        have flatpak && alias fr='flatpak run "$(flatpak list --columns=application | fzf)"'
        have systemctl && alias sysls="systemctl --type=service --state=running"
        ;;
esac

have nsxiv && alias img="nsxiv --thumbnail"
have mpv && alias play="mpv --shuffle ."
if [ -n "${DISPLAY:-}" ] && have xrandr; then
    alias bright="monitor bright"
    alias offmon="monitor off"
    alias onmon="monitor on"
    alias same="monitor same"
fi

[ -n "${ZSH_VERSION:-}" ] && setopt PROMPT_SUBST 2>/dev/null
if [ -n "${ZSH_VERSION:-}" ]; then _m1='%{'; _m2='%}'
elif [ -n "${BASH_VERSION:-}" ]; then _m1='\['; _m2='\]'
else _m1=''; _m2=''; fi
if [ -n "${SSH_CONNECTION:-}" ]; then
    _pid="[${USER:-$(id -un)}@$(hostname 2>/dev/null | cut -d. -f1)] "
else
    _pid=""
fi
if [ "$(id -u)" -eq 0 ]; then
    PS1="${_m1}$(printf '\033[31m')${_m2}${_pid}[\${PWD}] \$ ${_m1}$(printf '\033[0m')${_m2}"
else
    PS1="${_pid}[\${PWD}] \$ "
fi
export PS1
unset _m1 _m2 _pid

if have eza; then e; fi
