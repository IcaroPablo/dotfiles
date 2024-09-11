# verificar se o lf tá instalado

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
