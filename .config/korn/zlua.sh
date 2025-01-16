# verificar a instalação do lua
# verificar a instalação do zlua
# verificar a instalação do script "fzfprompt"
# a variável PS1 não pode ser sobrescrita para o funcionamento correto

eval "$(lua54 $HOME/.local/bin/z.lua --init posix legacy)"

cdz() {
    if [ "$1" = "" ]; then
        # command cd
        builtin cd
    fi

    # ultima alternativa não funciona
    # command cd "$1" 2> /dev/null || z -I "$1" || (echo "cd: File or Directory not found: $1" >&2 && exit 1)
    builtin cd "$1" 2> /dev/null || z -I "$1" || (echo "cd: File or Directory not found: $1" >&2 && exit 1)

    clear
    eza -lh --group-directories-first --color always | bat --color always --plain
}

cdzprompt() {
    message="directory query: "
    directory="$(fzfsimpleprompt "$message")"

    cdz "$directory"
}

alias "cd"="cdz"
