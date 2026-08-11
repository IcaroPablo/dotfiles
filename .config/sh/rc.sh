# rc.sh — portable interactive shell config. POSIX sh; loads cleanly under
# zsh, bash and ksh. Sourced from the shell's rc file via the wizard's block.
#
# It pulls the login env first (which also loads guard.sh and the per-OS
# fragment), then defines the portable navigation/file core.

: "${XDG_CONFIG_HOME:="$HOME/.config"}"
DOT_SH="$XDG_CONFIG_HOME/sh"

# env.sh is idempotent; sourcing it here covers non-login interactive shells.
[ -f "$DOT_SH/env.sh" ] && . "$DOT_SH/env.sh"
# Fallback: define have() if guard.sh was not pulled in for some reason.
command -v have >/dev/null 2>&1 || have() { command -v "$1" >/dev/null 2>&1; }

# --- privilege helper: prefer doas, fall back to sudo ---
if have doas; then DOAS='doas'; else DOAS='sudo'; fi

# --- shell options (best-effort; not every shell supports every option) ---
set -o vi 2>/dev/null || true
ulimit -c 0 2>/dev/null || true

# start in a given folder when asked (e.g. spawned terminals)
[ -n "${INITIAL_FOLDER:-}" ] && cd "$INITIAL_FOLDER"

# --- zoxide / z.lua (guarded) ---
if have lua && [ -f "$HOME/.local/bin/z.lua" ]; then
    eval "$(lua "$HOME/.local/bin/z.lua" --init posix legacy)"
elif have zoxide; then
    eval "$(zoxide init posix --cmd z 2>/dev/null)" 2>/dev/null || true
fi

# ------------------------------------------------------------------ functions

# e [args]: list the current (or given) directory. eza when present, else ls.
e() {
    clear 2>/dev/null || true
    if have eza; then
        eza -lh "$@" --group-directories-first --no-quotes --icons always --color always
    else
        ls -lhA "$@"
    fi
}

# c [target]: fuzzy/jump navigation. Opens files, cds into dirs, and uses the
# interactive selector otherwise. The z (jump) branch is used only if present.
c() {
    current_folder="$(pwd)"

    if [ -n "$1" ]; then
        if [ -f "$1" ]; then
            openfile "$@"
            return
        elif [ -d "$1" ]; then
            cd "$1" || return
        elif have z; then
            z -I "$1"
            if [ "$current_folder" != "$(pwd)" ]; then
                z --add "$1"
            else
                return
            fi
        else
            return
        fi
    fi

    temp="$(mktemp)"
    interactive-select openfile --dir-path "$temp"
    folder="$(cat "$temp")"
    rm -f "$temp"

    [ -n "$folder" ] && [ -d "$folder" ] && c "$folder"
    [ "$current_folder" != "$(pwd)" ] && e
}

# hist [arg] / hist - [arg]: list history matching arg; with '-', number the
# matches and rerun a chosen one (prefix the number with 'e' to edit first).
# Uses `fc -ln` + eval so it works the same in zsh, bash and ksh.
hist() {
    case "$1" in
        -)
            shift
            fc -l 1 | grep -F -- "$1" || return 0
            printf 'number (prefix with e to edit): '
            read -r n || return 0
            case "$n" in
                "") return 0 ;;
                e*) n="${n#e}"; fc "$n" ;;
                *)
                    _c="$(fc -ln "$n" "$n" 2>/dev/null)"
                    [ -n "$_c" ] && eval "$_c"
                    unset _c ;;
            esac ;;
        *)
            fc -ln 1 | grep -F -- "$1" || return 0 ;;
    esac
}

# see: tee to the terminal (pass a pipeline's output through to the tty).
see() { tee /dev/tty; }

# fuck: rerun the previous command prefixed with doas/sudo (or retry it if it
# was already privileged). Portable across zsh/bash/ksh via `fc -ln` + eval.
fuck() {
    _last="$(fc -ln -1 2>/dev/null | sed 's/^[[:space:]]*//')"
    case "$_last" in
        fuck*|"") _last="$(fc -ln -2 2>/dev/null | sed 's/^[[:space:]]*//')" ;;
    esac
    [ -n "$_last" ] || return 0
    case "$_last" in
        "$DOAS"*) eval "$_last" ;;
        *) eval "$DOAS $_last" ;;
    esac
    unset _last
}

# -------------------------------------------------------------------- aliases

alias a="create"
alias ci="c -i"
alias doas="${DOAS} "
alias ea="e -a"
alias f="findfile"
alias g="simplegrep"
alias nvim="launch_nvim"
alias of='cd "$(find . -type d -print | fzf)"'
alias oF='cd "$(find . -type d -print | fzf)" && nvim'
alias ot="fzf --preview 'bat --color always {}' | sed 's/ /\\\\ /g' | xargs -r nvim"
alias p="interactive-select --show-selected | xargs -I {} cp -Rv {} ."
alias m="interactive-select --show-selected | xargs -I {} mv -v {} ."
alias rm="rm -i"
alias s="interactive-select"
alias sa="interactive-select --show-hidden"
alias so="interactive-select openfile"
alias ss="split_scr"
alias t="trash"
alias u="cd .. && e"

# Git
alias gcm="git checkout master"
alias gpom="git pull origin master"
alias newb="git checkout master && git pull origin master && git checkout -b "

# --------------------------------------------------------------------- prompt

# Dynamic, generic, POSIX prompt: user@host fixed once, ${PWD} re-expanded each
# time the prompt is drawn (single-quoted). zsh needs PROMPT_SUBST for that.
[ -n "${ZSH_VERSION:-}" ] && setopt PROMPT_SUBST 2>/dev/null
__prompt_id="${USER:-$(id -un)}@$(hostname 2>/dev/null | cut -d. -f1)"
PS1='['"$__prompt_id"'] [${PWD}] $ '
export PS1

# List the directory on startup, but only when eza is present (matches the
# original behavior and avoids clearing the screen on minimal systems).
# Kept in an `if` so sourcing rc.sh exits 0 even when eza is absent.
if have eza; then e; fi
