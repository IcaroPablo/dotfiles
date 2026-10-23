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

# xrandr lists disconnected outputs too; the panel goes off only once mirrored
if xrandr | grep -q '^HDMI[^ ]* connected'; then
    monitor same && monitor off
fi

xset r rate 300 100
xset s off
xset b off
xset -dpms
# smawm's lock key (xset dpms force off) turns DPMS back on: no timeouts then
xset dpms 0 0 0

# PATH e o resto vêm herdados: o profile carrega o env.sh no login e é o
# env.sh que dispara o startx. Sem essa herança nada aqui embaixo resolve.

# wallpaper: a random image from ~/.local/wallpapers; awk, as OpenBSD has no shuf
_w=$(for _f in "$HOME"/.local/wallpapers/*; do
        [ -f "$_f" ] && printf '%s\n' "$_f"
    done | awk 'BEGIN { srand() } { a[NR] = $0 } END { if (NR) print a[int(rand() * NR) + 1] }')
[ -n "$_w" ] && xwallpaper --zoom "$_w" &
setxkbmap br &

# what only one OS has: ~/.config/x11/xinitrc.d/<os>.sh
_os=$(uname | tr '[:upper:]' '[:lower:]')
_x=${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc.d/$_os.sh
[ -f "$_x" ] && . "$_x"
unset _os _x

# tap to click and natural scrolling on every libinput touchpad, found by the
# tapping property (mice don't have it), not by name; on OpenBSD nothing matches
xinput list --name-only | while read -r _d; do
    xinput list-props "$_d" 2>/dev/null | grep -q 'libinput Tapping Enabled (' && {
        xinput set-prop "$_d" 'libinput Tapping Enabled' 1
        xinput set-prop "$_d" 'libinput Natural Scrolling Enabled' 1
    }
done

bar &

# Registra as variáveis do X11 na sessão D-Bus (resolve o xdg-desktop-portal)
dbus-update-activation-environment --all &

# run the WM in the foreground (no exec) so the ssh-agent teardown below runs on logout
smawm

# session ended: drop keys and stop the ssh-agent
if [ "$SSH_AGENT_PID" ]; then
    ssh-add -D < /dev/null
    eval `ssh-agent -s -k`
fi
