# cd into the directory lf was left in on quit. Only wire this up if lf exists.
if command -v lf >/dev/null 2>&1; then
    lfcd() {
        tmp="$(mktemp)"
        command lf -last-dir-path="$tmp" "$@"

        if [ -f "$tmp" ]; then
            dir="$(cat "$tmp")"
            rm -f "$tmp"

            [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
        fi
    }

    alias "lf"="lfcd"
fi
