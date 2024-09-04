#!/bin/zsh

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

file="$(fzf --preview 'bat --color always {}' | sed 's/ /\\ /g')"

if [ "$file" != "" ]; then
    current_path="$(pwd)"

    full_path="$current_path/$file"

    file_folder="$(dirname $full_path)"

    cd $file_folder

    cd $(git rev-parse --show-toplevel || pwd)

    echo $full_path

    nvim $full_path
fi
