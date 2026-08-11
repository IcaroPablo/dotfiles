# os.d/linux.sh — Linux-specific env + interactive bits. Sourced by env.sh.
# _path_prepend() and have() are already defined (env.sh / guard.sh).

# Flatpak exports on PATH.
[ -d /var/lib/flatpak/exports/bin ] && _path_prepend /var/lib/flatpak/exports/bin
export PATH

# Package/service helpers (guarded).
have flatpak && alias fr='flatpak run "$(flatpak list --columns=application | fzf)"'
have systemctl && alias sysls="systemctl --type=service --state=running"

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
