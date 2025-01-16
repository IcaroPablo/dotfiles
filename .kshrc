[ -f "/etc/ksh.kshrc" ] && . /etc/ksh.kshrc

[ -n "$INITIAL_FOLDER" ] && cd "$INITIAL_FOLDER"

# Setings

set -o vi
# set -o vi-tabcomplete
ulimit -c 0

if [ -x "$(which lua)" ] && [ -f "$HOME/.local/bin/z.lua" ]; then
    eval "$(lua54 $HOME/.local/bin/z.lua --init posix legacy)"
fi

# . $HOME/.profile
. $HOME/.config/korn/lf.sh

# Functions

e() {
    eza -lh $1 --group-directories-first --color always | bat --color always --plain
}

cd() {
    if [ "$1" = "" ]; then
        # command cd
        builtin cd
    fi

    # command cd "$1" 2> /dev/null || z -I "$1"
    builtin cd "$1" 2> /dev/null || z -I "$1"

    clear
    e
}

# cdzprompt() {
#     message="directory query: "
#     directory="$(fzfsimpleprompt "$message")"
#
#     cd "$directory"
# }

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
alias "ea"="e -a"
alias "f"="findfile"
alias "fr"="flatpak run \"\$(flatpak list --columns=application | fzf)\""
alias "g"="simplegrep"
alias "img"="nsxiv --thumbnail"
alias "nvim"="launch_nvim"
alias "o"="openfile"
alias "oF"='cd $(find . -type d -print | fzf) && nvim'
alias "of"='cd $(find . -type d -print | fzf)'
alias "offmon"="xrandr --output eDP-1 --off"
alias "onmon"="xrandr --output eDP-1 --auto"
alias "ot"="fzf --preview 'bat --color always {}' | sed 's/ /\\ /g' | xargs -r nvim"
alias "play"="mpv --shuffle ."
alias "rm"="rm -i"
alias "rr"="commandsearch"
alias "same"="xrandr --output HDMI-1 --same-as eDP-1"
alias "same"="xrandr --output eDP-1 --same-as HDMI-1"
alias "sensors"="systat -s 1 sensors"
alias "ss"="split_scr"

# Git
alias gcm="git checkout master"
alias gpom="git pull origin master"
alias newb="git checkout master && git pull origin master && git checkout -b "

# dvtm
# . $HOME/.local/scripts/skorn

e
