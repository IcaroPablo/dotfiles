# env.sh — portable login environment + per-OS setup, merged into one file.
# POSIX sh. Idempotent: safe to source more than once (a login shell that is
# also interactive sources it twice). Loaded by the shell's profile and, at the
# top of rc.sh, by every interactive shell. Pulls in guard.sh (have/abspath/…).
#
# Layout:
#   1. portable env (editor, pager, locale, PATH)
#   2. per-OS deltas — only what genuinely differs — via `case $(uname)`
#   3. the X11/dwm desktop block shared by Linux AND OpenBSD, keyed on
#      capabilities (have st / have xrandr / have startx), not OS name. macOS
#      has none of those binaries and skips it.

: "${XDG_CONFIG_HOME:="$HOME/.config"}"
DOT_SH="$XDG_CONFIG_HOME/sh"
export XDG_CONFIG_HOME

[ -f "$DOT_SH/lib/guard.sh" ] && . "$DOT_SH/lib/guard.sh"

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
if have nvim; then EDITOR='nvim'; MANPAGER='nvim +Man!'; else EDITOR='vi'; unset MANPAGER; fi
FCEDIT="$EDITOR"
export EDITOR FCEDIT
[ -n "${MANPAGER:-}" ] && export MANPAGER

if have bat; then PAGER='bat'; else PAGER='less'; fi
export PAGER

# --- locale / history / misc app env ---
export LANG="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_TIME="pt_PT.UTF-8"
export HISTFILE="$HOME/.sh_history"           # honored by sh/ksh; bash/zsh differ
export SKORN_EDITOR='nvim +"set ft=sh"' ENABLE_WASM=true

# --- rust (guarded) ---
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
_path_prepend "$HOME/.cargo/bin"

# ------------------------------------------------- per-OS deltas (real ones)
case "$(uname)" in
    OpenBSD)
        export AUDIOPLAYDEVICE="snd/0" AUDIORECDEVICE="snd/1"      # sndio
        [ -d /usr/local/jdk-17 ] && export JAVA_HOME=/usr/local/jdk-17
        [ -n "${JAVA_HOME:-}" ] && _path_prepend "$JAVA_HOME/bin"
        _path_prepend /usr/X11R6/bin
        _path_prepend /usr/games
        [ -n "${KSH_VERSION:-}" ] && [ -f /etc/ksh.kshrc ] && . /etc/ksh.kshrc

        # pkg helpers
        req() {
            _in=0
            printf "%s" "$(pkg_info "$1")" | while IFS= read -r _line; do
                if [ "$_in" = 0 ] && [ "$_line" = "Required by:" ]; then _in=1; continue; fi
                [ "$_in" = 1 ] && [ "$_line" = "" ] && _in=0
                [ "$_in" = 1 ] && printf '%s\n' "$_line"
            done
        }
        req_by() { pkg_info -f "$1" | grep '^@depend' | cut -f 3 -d :; }
        del() { doas pkg_delete "$1" && doas pkg_delete -a; }
        alias add="doas pkg_add -Dsnap"
        have ntpctl && alias chkclock="ntpctl -s all"
        have systat && alias sensors="systat -s 1 sensors"

        # ksh programmable completions (`complete` is a bash/zsh builtin — ksh only)
        if [ -n "${KSH_VERSION:-}" ]; then
            complete() {
                if have "$1"; then
                    typeset _cmd="$1" _num="$2"
                    shift 2
                    set -A "complete_${_cmd}${_num:+"_$_num"}" -- "$@"
                fi
            }
        fi
        ;;
    Linux)
        [ -d /var/lib/flatpak/exports/bin ] && _path_prepend /var/lib/flatpak/exports/bin
        have flatpak && alias fr='flatpak run "$(flatpak list --columns=application | fzf)"'
        have systemctl && alias sysls="systemctl --type=service --state=running"
        ;;
    Darwin)
        _path_prepend /opt/homebrew/bin
        _path_prepend /opt/homebrew/sbin
        _path_prepend /usr/local/bin
        _path_prepend /usr/local/sbin
        have wezterm && { TERM_CMD='wezterm start --'; NVIM_TERM_CMD='wezterm start --'; }
        ;;
esac
unset _d
export PATH

# ------------------------------------ X11 / dwm desktop (Linux + OpenBSD)
# Both run the same graphical world (dwm/st/nsxiv/mpv/xrandr), so a single block
# guarded by capability serves both — no per-OS duplication. macOS skips it all.
have st && { TERM_CMD='st -e'; NVIM_TERM_CMD='st -e'; }
[ -n "${TERM_CMD:-}" ] && export TERM_CMD NVIM_TERM_CMD

have nsxiv && alias img="nsxiv --thumbnail"
have mpv && alias play="mpv --shuffle ."

if [ -n "${DISPLAY:-}" ] && have xrandr; then
    alias bright="xrandr --output eDP-1 --brightness"
    alias offmon="xrandr --output eDP-1 --off"
    alias onmon="xrandr --output eDP-1 --auto"
    alias same="xrandr --output HDMI-1 --same-as eDP-1"
fi

# Start X automatically on the first console (Linux and OpenBSD alike).
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ] && have startx; then
    startx
fi
