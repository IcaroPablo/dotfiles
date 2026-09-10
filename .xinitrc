#!/bin/sh

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

# Nem o OpenBSD nem o Linux têm agente de sessão pronto como o launchd do macOS:
# um sobe aqui e cai no logout, no teardown lá embaixo. A lista de chaves sai do
# diretório, e não de nomes fixos -- o esqueleto do OpenBSD procurava id_rsa,
# id_dsa e companhia, e nenhuma das minhas se chama assim. Chave privada é o
# arquivo que tem um .pub ao lado. O < /dev/null é o que manda a senha ser pedida
# pelo askpass gráfico: aqui não há tty para o ssh-add perguntar.
if [ -z "$SSH_AGENT_PID" ] && command -v ssh-agent >/dev/null 2>&1; then
    _keys=''
    for _pub in "$HOME"/.ssh/*.pub; do
        _key="${_pub%.pub}"
        [ -f "$_key" ] && _keys="$_keys $_key"
    done
    if [ -n "$_keys" ]; then
        eval "$(ssh-agent -s)"
        ssh-add $_keys < /dev/null
    fi
    unset _pub _key _keys
fi

if [ "$(xrandr | grep HDMI)" != "" ]; then
    monitor same
    monitor off
fi

xset r rate 300 100
xset s off
xset b off
xset -dpms
xset dpms 0 0 0
#setterm -blank 0 -powerdown 0

# PATH e o resto vêm herdados: o profile carrega o env.sh no login e é o
# env.sh que dispara o startx. Sem essa herança nada aqui embaixo resolve.

# papel de parede. As imagens não são versionadas — moram fora do repo, e o
# current é um symlink apontando para a escolhida. Máquina sem elas apenas
# não põe papel de parede: o -f cobre tanto o arquivo ausente quanto o
# symlink quebrado. O --no-fehbg impede o feh de deixar um ~/.fehbg para trás,
# que é como o caminho absoluto voltaria a ficar embutido em arquivo nenhum.
_w="$HOME/Downloads/wallpapers/current"
[ -f "$_w" ] && feh --no-fehbg --bg-scale "$_w" &
# setxkbmap -device `xinput list | grep "Virtual core XTEST keyboard" | sed -e 's/.\+=\([0-9]\+\).\+/\1/'` br &
# setxkbmap -device `xinput list | grep "Virtual core XTEST keyboard" | sed -e 's/.*=//' | awk '{print $1}'` br &
setxkbmap br &

if [ "$(uname)" = OpenBSD ]; then
    mid=$(xinput list | grep /dev/wsmouse | awk '{print $4}' | sed 's/id=//')
    mad=$(xinput list-props "$mid" | grep 'Device Accel Constant Deceleration' | awk '{print $5}' | sed 's/[():]//g')
    [ -n "$mid" ] && [ -n "$mad" ] && xinput set-prop "$mid" "$mad" 2
fi

bar &

# Registra as variáveis do X11 na sessão D-Bus (resolve o xdg-desktop-portal)
dbus-update-activation-environment --all &

# run the WM in the foreground (no exec) so the ssh-agent teardown below runs on logout
smawm
# while true; do smawm; done
# xhost +SI:localuser:$USER

# session ended: drop keys and stop the ssh-agent
if [ "$SSH_AGENT_PID" ]; then
    ssh-add -D < /dev/null
    eval `ssh-agent -s -k`
fi
