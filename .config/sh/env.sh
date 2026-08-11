# env.sh — portable login environment. POSIX sh. Idempotent: safe to source
# more than once (a login shell that is also interactive sources it twice).
#
# Loaded by: the shell's profile (via the wizard's injected block) and, at the
# top of rc.sh, by every interactive shell. It pulls in guard.sh and, last, the
# per-OS fragment in os.d/, which carries both OS env and OS interactive bits.

: "${XDG_CONFIG_HOME:="$HOME/.config"}"
DOT_SH="$XDG_CONFIG_HOME/sh"
export XDG_CONFIG_HOME

# guard.sh: have()/abspath()/os_open(), used here and by os.d fragments.
[ -f "$DOT_SH/lib/guard.sh" ] && . "$DOT_SH/lib/guard.sh"

# _path_prepend <dir>: add <dir> to the front of PATH only if it exists and is
# not already present. Keeps repeated sourcing from stacking duplicates.
_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) : ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

_path_prepend "$HOME/.local/bin"
_path_prepend "$HOME/.local/scripts"

# --- Editor / pager (guarded: degrade instead of pointing at a missing tool) ---
if command -v nvim >/dev/null 2>&1; then
    EDITOR='nvim'
    MANPAGER='nvim +Man!'
else
    EDITOR='vi'
    unset MANPAGER
fi
FCEDIT="$EDITOR"
export EDITOR FCEDIT
[ -n "${MANPAGER:-}" ] && export MANPAGER

if command -v bat >/dev/null 2>&1; then
    PAGER='bat'
else
    PAGER='less'
fi
export PAGER

# --- Locale ---
export LANG="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_TIME="pt_PT.UTF-8"

# --- History (honored by sh/ksh; bash/zsh keep their own HISTFILE) ---
export HISTFILE="$HOME/.sh_history"

# --- Misc app env (harmless everywhere) ---
export SKORN_EDITOR='nvim +"set ft=sh"'
export ENABLE_WASM=true

# --- Rust (guarded) ---
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
_path_prepend "$HOME/.cargo/bin"

export PATH

# --- Per-OS fragment (env + interactive bits, each guarded inside) ---
case "$(uname)" in
    Darwin)  _dot_os="darwin" ;;
    Linux)   _dot_os="linux" ;;
    OpenBSD) _dot_os="openbsd" ;;
    *)       _dot_os="" ;;
esac
[ -n "$_dot_os" ] && [ -f "$DOT_SH/os.d/$_dot_os.sh" ] && . "$DOT_SH/os.d/$_dot_os.sh"
unset _dot_os
