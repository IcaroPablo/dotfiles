# env.sh — portable login environment: EXPORTED VARIABLES ONLY. POSIX sh.
#
# Sourced ONCE per login by the shell's profile (via the wizard's block).
# Interactive shells inherit these exported variables from their login ancestor,
# so env.sh is NOT re-sourced per session. Functions and aliases (which are not
# inheritable) live in rc.sh instead.
#
# Layout: portable env, then per-OS env deltas via `case $(uname)`, then the
# exported terminal launcher and the tty1 auto-startx (a login-time action).

: "${XDG_CONFIG_HOME:="$HOME/.config"}"
export XDG_CONFIG_HOME

# add <dir> to the front of PATH only if it exists and is not already there
_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) : ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

_path_prepend "$HOME/.local/bin"
_path_prepend "$HOME/.local/scripts"

# --- editor / pager (guarded: degrade instead of pointing at a missing tool) ---
if command -v nvim >/dev/null 2>&1; then EDITOR='nvim'; MANPAGER='nvim +Man!'; else EDITOR='vi'; unset MANPAGER; fi
FCEDIT="$EDITOR"
export EDITOR FCEDIT
[ -n "${MANPAGER:-}" ] && export MANPAGER

if command -v bat >/dev/null 2>&1; then PAGER='bat'; else PAGER='less'; fi
export PAGER

# --- locale / history / misc app env ---
export LANG="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_TIME="pt_PT.UTF-8"
export HISTFILE="$HOME/.sh_history"           # honored by sh/ksh; bash/zsh differ
export SKORN_EDITOR='nvim +"set ft=sh"' ENABLE_WASM=true

# --- rust (guarded) ---
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
_path_prepend "$HOME/.cargo/bin"

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

# Terminal launcher — EXPORTED because split_scr/openfile read it in separate
# processes. st on the dwm/X11 boxes (Linux + OpenBSD), wezterm on macOS.
if command -v st >/dev/null 2>&1; then
    TERM_CMD='st -e'; NVIM_TERM_CMD='st -e'
elif command -v wezterm >/dev/null 2>&1; then
    TERM_CMD='wezterm start --'; NVIM_TERM_CMD='wezterm start --'
fi
[ -n "${TERM_CMD:-}" ] && export TERM_CMD NVIM_TERM_CMD

# Start X automatically on the first console (Linux and OpenBSD). This is a
# login-time action; env.sh is sourced once per login, so it fires just once.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && command -v startx >/dev/null 2>&1; then
    startx
fi
