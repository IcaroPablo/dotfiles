# env.sh — portable login environment: EXPORTED VARIABLES ONLY. POSIX sh.

# Sourced ONCE per login by the shell's profile (the two lines in the README).
# Interactive shells inherit these exported variables from their login ancestor,
# so env.sh is NOT re-sourced per session. Functions and aliases (which are not
# inheritable) live in rc.sh instead.

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

# --- locale ---
export LANG="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_TIME="pt_PT.UTF-8"

# ------------------------------------------------- per-OS env deltas (real ones)
case "$(uname)" in
    OpenBSD)
        export AUDIOPLAYDEVICE="snd/0" AUDIORECDEVICE="snd/1"      # sndio
        # the newest of the jdk-NN packages
        if [ -z "${JAVA_HOME:-}" ]; then
            for _j in /usr/local/jdk-*; do [ -d "$_j" ] && JAVA_HOME=$_j; done
            unset _j
        fi
        [ -n "${JAVA_HOME:-}" ] && export JAVA_HOME && _path_prepend "$JAVA_HOME/bin"
        _path_prepend /usr/X11R6/bin
        _path_prepend /usr/games
        ;;
    Linux)
        _path_prepend /var/lib/flatpak/exports/bin
        export LIBSEAT_BACKEND=logind
        ;;
esac
export PATH
unset -f _path_prepend

if command -v nvim >/dev/null 2>&1; then EDITOR='nvim'; MANPAGER='nvim +Man!'; else EDITOR='vi'; unset MANPAGER; fi
FCEDIT="$EDITOR"
export EDITOR FCEDIT
[ -n "${MANPAGER:-}" ] && export MANPAGER

# login-time action; env.sh is sourced once per login, so it fires just once.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && command -v startx >/dev/null 2>&1; then
    startx
fi
