# X helpers, for scripts that reach the screen (X only, by design); sourced
# after core.sh

has_x() { [ -n "${DISPLAY:-}" ]; }

# clip_copy file [type]: the file onto the X clipboard, as type (text by
# default). nohup: xclip stays behind serving it, and a closing terminal's
# SIGHUP would take the selection with it
clip_copy() {
    has_x && have xclip || { printf 'clip_copy: needs X and xclip\n' >&2; return 1; }
    nohup xclip -selection clipboard ${2:+-t "$2"} -i "$1" >/dev/null
}

# gui_open file...: each file in its X application, in the background
gui_open() {
    has_x || return 1
    have xdg-open || { printf 'gui_open: no xdg-open\n' >&2; return 1; }
    for _go in "$@"; do
        if have setsid; then setsid xdg-open "$_go" >/dev/null 2>&1 &
        else xdg-open "$_go" >/dev/null 2>&1 &
        fi
    done
    unset _go
}
