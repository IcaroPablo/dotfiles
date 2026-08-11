# os.d/openbsd.sh — OpenBSD-specific env + interactive bits. Sourced by env.sh.
# _path_prepend() and have() are already defined (env.sh / guard.sh).

# Global ksh rc — only when actually running ksh.
[ -n "${KSH_VERSION:-}" ] && [ -f /etc/ksh.kshrc ] && . /etc/ksh.kshrc

# sndio audio devices.
export AUDIOPLAYDEVICE="snd/0"
export AUDIORECDEVICE="snd/1"

# Java (OpenBSD package layout).
[ -d /usr/local/jdk-17 ] && export JAVA_HOME=/usr/local/jdk-17
[ -n "${JAVA_HOME:-}" ] && _path_prepend "$JAVA_HOME/bin"

# OpenBSD X11 / games base paths.
for _d in /usr/X11R6/bin /usr/games; do
    [ -d "$_d" ] && _path_prepend "$_d"
done
unset _d
export PATH

# ------------------------------------------------------------- pkg_* helpers

# req <pkg>: list the packages that require <pkg> (the "Required by:" block).
req() {
    _in=0
    printf "%s" "$(pkg_info "$1")" | while IFS= read -r _line; do
        if [ "$_in" = 0 ] && [ "$_line" = "Required by:" ]; then _in=1; continue; fi
        [ "$_in" = 1 ] && [ "$_line" = "" ] && _in=0
        [ "$_in" = 1 ] && printf '%s\n' "$_line"
    done
}

# req_by <pkg>: list the packages <pkg> depends on.
req_by() { pkg_info -f "$1" | grep '^@depend' | cut -f 3 -d :; }

# del <pkg>: delete <pkg> then prune orphaned dependencies.
del() { doas pkg_delete "$1" && doas pkg_delete -a; }

alias add="doas pkg_add -Dsnap"
have ntpctl && alias chkclock="ntpctl -s all"
have systat && alias sensors="systat -s 1 sensors"

# X11 media viewers (guarded).
have nsxiv && alias img="nsxiv --thumbnail"
have mpv && alias play="mpv --shuffle ."

# X11 display controls — only meaningful inside an X session.
if [ -n "${DISPLAY:-}" ] && have xrandr; then
    alias bright="xrandr --output eDP-1 --brightness"
    alias offmon="xrandr --output eDP-1 --off"
    alias onmon="xrandr --output eDP-1 --auto"
    alias same="xrandr --output HDMI-1 --same-as eDP-1"
fi

# Terminal launcher (st) for split_scr / nvim term integration.
if have st; then
    TERM_CMD='st -e'
    NVIM_TERM_CMD='st -e'
    export TERM_CMD NVIM_TERM_CMD
fi

# ------------------------------------------- ksh programmable completions
# `complete` collides with a bash/zsh builtin, so it only exists under ksh.
if [ -n "${KSH_VERSION:-}" ]; then
    # complete <cmd> <num> <words...>: register completion words for <cmd> when
    # <cmd> exists. Add specific completion tables below as needed.
    complete() {
        if have "$1"; then
            typeset _cmd="$1" _num="$2"
            shift 2
            set -A "complete_${_cmd}${_num:+"_$_num"}" -- "$@"
        fi
    }
fi

# Start X automatically on the first console (login phase only).
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && have startx; then
    startx
fi
