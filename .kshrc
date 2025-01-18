# load global kshrc
[ -f "/etc/ksh.kshrc" ] && . /etc/ksh.kshrc

[ -n "$INITIAL_FOLDER" ] && cd "$INITIAL_FOLDER"

[ -x "$(which doas)" ] && DOAS='doas' || DOAS='sudo'

# Setings

# set -o braceexpand
set -o vi
# set -o vi-tabcomplete

ulimit -c 0

if [ -x "$(which lua)" ] && [ -f "$HOME/.local/bin/z.lua" ]; then
    eval "$(lua $HOME/.local/bin/z.lua --init posix legacy)"
fi

# . $HOME/.profile
# . $HOME/.config/korn/zlua.sh
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

# tee to terminal
see() {
	tee /dev/tty
}

# check if command exists and set list of completions for it
complete() {
	if [ -x "$(which $1)" ]; then
		typeset cmd="$1"
		typeset num="$2"
		shift 2
		set -A "complete_${cmd}${num:+"_$num"}" -- "$@"
	fi
}

# alias x="ssh -YC4c aes128-cbc treebeard@192.168.1.21 'x2x -west -to :0'"
# alias x='ssh -YC4 -c aes128-cbc treebeard@192.168.1.21 '\''x2x -east -to :0'\'
# x() {
#     eval "ssh -YC4 icaro@192.168.1.$1 'x2x -east -to :0'"
# }

# Aliases

alias a="create"
alias add="doas pkg_add -Dsnap"
alias bright="xrandr --output eDP-1 --brightness"
alias chkclock="ntpctl -s all"
alias doas="${DOAS} "   # doas <- sudo
alias ea="e -a"
alias f="findfile"
alias fr="flatpak run \"\$(flatpak list --columns=application | fzf)\""
alias g="simplegrep"
alias img="nsxiv --thumbnail"
alias nvim="launch_nvim"
alias o="openfile"
alias oF='cd $(find . -type d -print | fzf) && nvim'
alias of='cd $(find . -type d -print | fzf)'
alias offmon="xrandr --output eDP-1 --off"
alias onmon="xrandr --output eDP-1 --auto"
alias ot="fzf --preview 'bat --color always {}' | sed 's/ /\\ /g' | xargs -r nvim"
alias play="mpv --shuffle ."
alias rm="rm -i"
alias rr="commandsearch"
alias same="xrandr --output HDMI-1 --same-as eDP-1"
alias same="xrandr --output eDP-1 --same-as HDMI-1"
alias sensors="systat -s 1 sensors"
alias ss="split_scr"

#seninha's
# alias cp="cp -Riv"      # recursive, interactive, verbose cp
# alias mv="mv -iv"       # interactive, verbose mv
# alias rm='rm -rv'       # recursive, verbose rm
# alias hex='hexdump -C'  # sane hexdump
# alias od='od -cAx'      # sane od
# alias df='df -h'        # df with human readable sizes
# alias du='du -hc'       # du with human readable sizes and grand total
# alias doas="${DOAS} "   # doas <- sudo
# alias dira='dir -a'     # list all dir (our colortree function, see above)
# alias da='dir -a'       # list all dir (our colortree function, see above)
# alias l='less'          # lazyman less
# alias v='vim'           # lazyman vim
# alias c='cd'            # lazyman cd
# alias d='dir'           # lazyman dir
# alias r='readme'        # lazyman readme
# alias scheme='rlwrap -q\" chibi-scheme'         # interactive scheme REPL


# Git
alias gcm="git checkout master"
alias gpom="git pull origin master"
alias newb="git checkout master && git pull origin master && git checkout -b "

# Completions

# complete skel 1 $(\ls -1F "$SKEL" | sed 's/\*$//')       # skel is a template system I created
# complete make "" $(make -qp 2>/dev/null | sed -n '/^[A-Za-z][^ :]* *:/{s/\([^: ]*\).*/\1/p;}')
# complete sysctl "" $(sysctl | sed 's/[ =].*//')
# complete rcctl 1 disable enable get ls order set restart start stop
# complete rcctl 2 $(rcctl ls all)
# complete git 1 $(git --list-cmds=main)
# complete mpc 1 $(mpc help | awk '$1 == "mpc" { print $2 }')
# complete mpc 2 $(pgrep -q mpd && mpc lsplaylists | sort)
# complete kill 1 -9 -HUP -INFO -KILL -TERM
# complete pkill 1 -9 -HUP -INFO -KILL -TERM
# complete ssh "" $(test -r "$HOME/.ssh/config" && awk '$1 == "Host" {print $2}' "$HOME/.ssh/config")
# complete ifconfig 1 $(ifconfig | grep '^[a-z]' | cut -d: -f1)
# complete vmctl 1 console load reload start stop reset status send receive
# pgrep -q vmd && complete vmctl "" $(vmctl status | awk '!/NAME/{print $NF}')

# print previous command's non-zero exit status, bold and red, after it exits
# trap 'printf "\e[1;31mEXIT: %s\e[0m\n" "$?"' ERR

# dvtm
# . $HOME/.local/scripts/skorn

e
