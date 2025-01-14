!/bin/sh

# $OpenBSD: xinitrc.cpp,v 1.13 2015/10/17 08:25:11 matthieu Exp $
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi
if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# if we have private ssh key(s), start ssh-agent and add the key(s)
id1=$HOME/.ssh/identity
id2=$HOME/.ssh/id_dsa
id3=$HOME/.ssh/id_rsa
id4=$HOME/.ssh/id_ecdsa
id5=$HOME/.ssh/id_ed25519

if [ -z "$SSH_AGENT_PID" ]; then
	if [ -x /usr/bin/ssh-agent ] && [ -f $id1 -o -f $id2 -o -f $id3 -o -f $id4 -o -f $id5]; then
        eval `ssh-agent -s`
        ssh-add < /dev/null
    fi
fi

# start some nice programs
# xclock -geometry 50x50-1+1 &
# xconsole -iconic &
# xterm -geometry 80x24 &
# fvwm || xterm
if [ "$SSH_AGENT_PID" ]; then
    ssh-add -D < /dev/null
    eval `ssh-agent -s -k`
fi

xset r rate 300 100
xset s off
xset b off
xset -dpms
xset 0 0 0
#setterm -blank 0 -powerdown 0

. $HOME/.profile
$HOME/.fehbg &
# setxkbmap -device `xinput list | grep "Virtual core XTEST keyboard" | sed -e 's/.\+=\([0-9]\+\).\+/\1/'` br &
setxkbmap -device `xinput list | grep "Virtual core XTEST keyboard" | sed -e 's/.*=//' | awk '{print $1}'` br &
setxkbmap br &
bar.sh &
# exec dwm
exec startdwm
# exec sowm
# xhost +SI:localuser:$USER
# exec distrobox enter -T -n arch -- xmonad
