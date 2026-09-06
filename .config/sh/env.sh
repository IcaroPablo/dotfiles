# env.sh — portable login environment: EXPORTED VARIABLES ONLY. POSIX sh.
#
# Sourced ONCE per login by the shell's profile (via the wizard's block).
# Interactive shells inherit these exported variables from their login ancestor,
# so env.sh is NOT re-sourced per session. Functions and aliases (which are not
# inheritable) live in rc.sh instead.
#
# Layout: portable env, then per-OS env deltas via `case $(uname)`, then the
# exported terminal launcher and the tty1 auto-startx (a login-time action).

# DOT_ROOT — a raiz destes dotfiles: o diretório que contém .config/ e .local/.
# Hoje é o $HOME, porque o bare repo tem o $HOME como work-tree, então o default
# preserva o comportamento atual. Ter a raiz numa variável é o que permite
# apontar esta mesma configuração para um clone em outro lugar — uma sessão
# volátil numa máquina alheia — sem editar nada aqui.
: "${DOT_ROOT:="$HOME"}"
export DOT_ROOT

: "${XDG_CONFIG_HOME:="$DOT_ROOT/.config"}"
export XDG_CONFIG_HOME

# add <dir> to the front of PATH only if it exists and is not already there
_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) : ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

# .local/bin é do hospedeiro (cargo, pip, go install); .local/scripts é conteúdo
# deste repo. Mesmo pai, tratamentos opostos: o primeiro segue no $HOME, o
# segundo acompanha o DOT_ROOT.
_path_prepend "$HOME/.local/bin"
_path_prepend "$DOT_ROOT/.local/scripts"

# --- editor / pager (guarded: degrade instead of pointing at a missing tool) ---
if command -v nvim >/dev/null 2>&1; then EDITOR='nvim'; MANPAGER='nvim +Man!'; else EDITOR='vi'; unset MANPAGER; fi
FCEDIT="$EDITOR"
export EDITOR FCEDIT
[ -n "${MANPAGER:-}" ] && export MANPAGER

if command -v bat >/dev/null 2>&1; then PAGER='bat'; else PAGER='less'; fi
export PAGER

# --- locale / history / misc app env ---
export LANG="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_TIME="pt_PT.UTF-8"
export ENABLE_WASM=true

# terminfo próprio, quando existir: numa máquina alheia o TERM do ghostty não
# está no banco do sistema, e sem isto a sessão cai num TERM degradado. Compilar
# com `tic -x -o "$DOT_ROOT/.local/terminfo" .config/ghostty/*.info`. A entrada
# vazia no fim mantém os diretórios padrão do sistema na busca.
if [ -d "$DOT_ROOT/.local/terminfo" ]; then
    export TERMINFO_DIRS="$DOT_ROOT/.local/terminfo:${TERMINFO_DIRS:-}"
fi

# --- rust (guarded) ---
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
_path_prepend "$HOME/.cargo/bin"

# --- go (guarded) ---
export GOPATH="$HOME/.go"
_path_prepend "$GOPATH/bin"

# ------------------------------------------------- per-OS env deltas (real ones)
case "$(uname)" in
    OpenBSD)
        export AUDIOPLAYDEVICE="snd/0" AUDIORECDEVICE="snd/1"      # sndio
        [ -d /usr/local/jdk-17 ] && export JAVA_HOME=/usr/local/jdk-17
        [ -n "${JAVA_HOME:-}" ] && _path_prepend "$JAVA_HOME/bin"
        _path_prepend /usr/X11R6/bin
        _path_prepend /usr/games
        ;;
    Linux)
        [ -d /var/lib/flatpak/exports/bin ] && _path_prepend /var/lib/flatpak/exports/bin
        ;;
    Darwin)
        _path_prepend /opt/homebrew/bin
        _path_prepend /opt/homebrew/sbin
        _path_prepend /usr/local/bin
        _path_prepend /usr/local/sbin
        ;;
esac
export PATH

# Terminal launcher — EXPORTED porque split_scr e dw leem em outro processo.
# st nas máquinas dwm/X11 (Linux + OpenBSD), wezterm no macOS.
if command -v st >/dev/null 2>&1; then
    TERM_CMD='st -e'
elif command -v wezterm >/dev/null 2>&1; then
    TERM_CMD='wezterm start --'
fi
[ -n "${TERM_CMD:-}" ] && export TERM_CMD

# Start X automatically on the first console (Linux and OpenBSD). This is a
# login-time action; env.sh is sourced once per login, so it fires just once.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && command -v startx >/dev/null 2>&1; then
    startx
fi
