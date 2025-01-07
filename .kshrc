[ -f "/etc/ksh.kshrc" ] && . /etc/ksh.kshrc

[ -n "$INITIAL_FOLDER" ] && cd "$INITIAL_FOLDER"

# Setings

set -o vi
# set -o vi-tabcomplete
ulimit -c 0

# Variables

. $HOME/.profile
. $HOME/.config/korn/zlua.sh
. $HOME/.config/korn/lf.sh

# Functions

simplegrep() {
    # rg -n --hidden "$1" ./* || grep -nRI "$1" ./*
    grep -nRIi "$1" ./*
}

req() {
    #TODO: should turn this into a tree
    in=0

    printf "%s" "$(pkg_info $1)" | while IFS= read -r line; do
        if [ "$in" = 0 ] && [ "$line" = "Required by:" ]; then
            in=1
            continue
        fi

        [ "$in" = 1 ] && [ "$line" = "" ] && in=0
        [ "$in" = 1 ] && printf "$line\n"
    done
}

req_by() {
    pkg_info -f "$1" | grep '^@depend' | cut -f 3 -d :
}

del() {
    doas pkg_delete "$1" && doas pkg_delete -a
}

# alias x="ssh -YC4c aes128-cbc treebeard@192.168.1.21 'x2x -west -to :0'"
# alias x='ssh -YC4 -c aes128-cbc treebeard@192.168.1.21 '\''x2x -east -to :0'\'
# x() {
#     eval "ssh -YC4 icaro@192.168.1.$1 'x2x -east -to :0'"
# }

# Aliases

alias "a"="create"
alias "add"="doas pkg_add -Dsnap"
alias "bright"="xrandr --output eDP-1 --brightness"
alias "chkclock"="ntpctl -s all"
alias "f"="findfile"
alias "g"="simplegrep"
# alias "htop"="TERM=xterm-256color && htop"
alias "img"="nsxiv --thumbnail"
alias "la"="ls -a"
alias "ls"="eza -lh --group-directories-first"
alias "nvim"="launch_nvim"
alias "o"="openfile"
alias "offmon"="xrandr --output eDP-1 --off"
alias "onmon"="xrandr --output eDP-1 --auto"
alias "play"="mpv --shuffle ."
alias "rm"="rm -i"
alias "rr"="commandsearch"
alias "ss"="split_scr"
alias "oF"='cd $(find . -type d -print | fzf) && nvim'
alias "of"='cd $(find . -type d -print | fzf)'
alias "ot"="fzf --preview 'bat --color always {}' | sed 's/ /\\ /g' | xargs -r nvim"

# Git
alias gcm="git checkout master"
alias gpom="git pull origin master"
alias newb="git checkout master && git pull origin master && git checkout -b "

# dvtm
# . $HOME/.local/scripts/skorn

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
