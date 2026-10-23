# zsh, entered as `emulate sh -c '. rc.sh'` (see the README): what rc.sh
# defines keeps sh's rules, but the prompt is drawn under zsh's, with %/ for the
# folder and %{ %} around the colour codes
_cwd='%/' _m1='%{' _m2='%}'
bindkey -v
# zsh sets HISTSIZE=30 and SAVEHIST=0 (no history file) itself, so rc.sh's
# defaults don't apply; and its file isn't ksh's
HISTSIZE=10000 SAVEHIST=10000
[ "$HISTFILE" != "$HOME/.sh_history" ] || HISTFILE=$HOME/.zsh_history
