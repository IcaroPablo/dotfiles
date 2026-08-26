: "${XDG_CONFIG_HOME:="$HOME/.config"}"

[ -f "$XDG_CONFIG_HOME/sh/lib/guard.sh" ] && . "$XDG_CONFIG_HOME/sh/lib/guard.sh"
command -v have >/dev/null 2>&1 || have() { command -v "$1" >/dev/null 2>&1; }

if have doas; then DOAS='doas'; else DOAS='sudo'; fi

set -o vi 2>/dev/null || true
ulimit -c 0 2>/dev/null || true

[ -n "${INITIAL_FOLDER:-}" ] && cd "$INITIAL_FOLDER"

e() {
    clear 2>/dev/null || true
    eza -lh "$@" --group-directories-first --no-quotes --icons always --color always
}

# ponto único de navegação e abertura. todo diretório alcançado por aqui é
# registrado no zoxide -- é o que substitui o hook do `zoxide init`:
#   c <dir>        cd
#   c <arquivo>…   openfile
#   c <query>      salto no zoxide: match único vai direto, ambíguo abre o picker
c() {
    [ -n "$1" ] || return
    _c_start="$(pwd)"

    if [ -f "$1" ]; then
        openfile "$@"
    elif [ -d "$1" ]; then
        cd "$1" || { unset _c_start; return; }
    # query -l sai 0 com stdout vazio quando não há match
    elif have zoxide && _c_hits="$(zoxide query -l -- "$1" 2>/dev/null)" && [ -n "$_c_hits" ]; then
        if [ "$(printf '%s\n' "$_c_hits" | wc -l | tr -d '[:space:]')" = 1 ]; then
            _c_hit="$_c_hits"
        else
            _c_hit="$(zoxide query -i -- "$1" 2>/dev/null)"
        fi
        [ -n "$_c_hit" ] && cd "$_c_hit"
    else
        printf 'c: %s: sem match\n' "$1" >&2
    fi

    if [ "$_c_start" != "$(pwd)" ]; then
        have zoxide && zoxide add -- "$(pwd)"
        e
    fi
    unset _c_start _c_hits _c_hit
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

p() { [ -s "$CLIPFILE" ] || return; while IFS= read -r _e; do cp -Rv -- "$_e" .; done < "$CLIPFILE"; unset _e; }
m() { [ -s "$CLIPFILE" ] || return; while IFS= read -r _e; do mv -v -- "$_e" .; done < "$CLIPFILE"; : > "$CLIPFILE"; unset _e; }

# único selecionador. sem argumento só enche o clipboard, para p e m; com
# argumento, o primeiro é um comando e a seleção vira o final dos args dele
sel() {
    if [ -n "$1" ]; then _sel_cmd="$1"; shift; else _sel_cmd=""; fi
    _sel_ls='eza -1 --group-directories-first --no-quotes --icons always --color always'

    _sel_out="$(eza -1 --group-directories-first --no-quotes --icons always --color always | fzf \
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
        --bind "alt-h:reload($_sel_ls -a)" \
        --bind "alt-H:reload($_sel_ls)" \
        --bind 'ctrl-l:accept' \
        --height 100% \
        --color=bg+:-1 \
        --border=sharp \
        --info=inline \
        --reverse \
        --preview 'p={}; preview "${p#* }"')" || return
    [ -n "$_sel_out" ] || return 1

    # o ícone do eza é um glifo mais um espaço; ${x#* } corta por byte e não por
    # caractere, então não depende do locale
    while IFS= read -r _sel_l; do abspath "${_sel_l#* }"; done > "$CLIPFILE" <<EOF
$_sel_out
EOF

    while IFS= read -r _sel_e; do set -- "$@" "$_sel_e"; done < "$CLIPFILE"
    [ -n "$_sel_cmd" ] && "$_sel_cmd" "$@"
    unset _sel_cmd _sel_ls _sel_out _sel_l _sel_e
}

# o -c cria o fifo de comandos e exporta DVTM_CMD_FIFO aos painéis: é por ele que
# o nvim pede um painel novo
#
# DVTM_OUTER_TERM é o TERM que o dvtm usa para pintar no terminal de verdade --
# só faz sentido por máquina, então mora no rc local (.zshrc, .kshrc), não aqui.
# Serve para apontar o dvtm a uma descrição com RGB, que é a única coisa que faz
# o ncurses mandar cor de 24 bits. Vazio, e nada muda.
#
# Não confundir com DVTM_TERM, que é do próprio dvtm e diz o TERM dos painéis.
# Este é o de fora; aquele é o de dentro.
#
# env, e não "TERM=... dvtm": a segunda forma faz o próprio shell tentar carregar
# a descrição, e um ncurses antigo pode não conseguir lê-la -- o da Apple não
# consegue ler as de cor direta.
dvtm() {
    if [ -n "$DVTM_OUTER_TERM" ]; then
        env TERM="$DVTM_OUTER_TERM" dvtm -c "${TMPDIR:-/tmp}/dvtm.$$.cmd" "$@"
    else
        command dvtm -c "${TMPDIR:-/tmp}/dvtm.$$.cmd" "$@"
    fi
}

alias a="create"
alias doas="${DOAS} "
alias ea="e -a"
alias f="findfile"
alias g="simplegrep"
alias nvim="launch_nvim"
alias rm="rm -i"
alias s="sel"
alias sc="sel c"
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

e
