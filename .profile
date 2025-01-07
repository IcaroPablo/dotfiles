# $OpenBSD: dot.profile,v 1.7 2020/01/24 02:09:51 okan Exp $
#
# sh/ksh initialization

PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games
export PATH HOME TERM

# inserted by me

# export AUDIODEVICE='snd@192.168.1.23/0'
export AUDIOPLAYDEVICE="snd/0"
export AUDIORECDEVICE="snd/1"
export EDITOR='nvim'
export ENABLE_WASM=true
export ENV=$HOME/.kshrc
export FCEDIT='nvim'
# export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# export HISTFILE=$HOME/.sh_history
export JAVA_HOME=/usr/local/jdk-17
# export JAVA_HOME=/usr/local/jdk-11
export LANG="en_US.UTF-8"
export LC_ALL=
# export LC_COLLATE="pt_PT.UTF-8"
# export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
# export LC_MONETARY="pt_PT.UTF-8"
# export LC_NUMERIC="pt_PT.UTF-8"
export LC_TIME="pt_PT.UTF-8"
export MANPAGER="nvim +Man!"
export NVIM_TERM_CMD="st -e"
export PAGER='bat'
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/lib/python3.10/site-packages:$PATH
export PATH=$HOME/.local/scripts/:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export PS1="[$(whoami)@$(hostname -s)] [\$PWD] $ "
#NL=$'\n'
#PROMPT="┌[%F{cyan}%n%f@%F{cyan}%m%f] [%F{cyan}%y%f]${NL}└[%F{cyan}%d%f] "
#PROMPT="%F{yellow}┌[%f%n%F{yellow}@%f%m%F{yellow}] [%f%y%F{yellow}]${NL}└[%f%d%F{yellow}]%f $ "
export SKORN_EDITOR='nvim +"set ft=sh"'
export TERM_CMD="st -e"

# Added by Toolbox App
export PATH="$PATH:/home/icaro/.local/share/JetBrains/Toolbox/scripts"
