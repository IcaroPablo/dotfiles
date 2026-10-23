# OpenBSD, sourced by rc.sh before its own aliases so they win over the
# system's; the system's alias p (ps -l) would break rc.sh's p()
if [ -n "${KSH_VERSION:-}" ] && [ -f /etc/ksh.kshrc ]; then
    . /etc/ksh.kshrc
    unalias p 2>/dev/null
fi

req() {
    _in=0
    printf "%s" "$(pkg_info "$1")" | while IFS= read -r _line; do
        if [ "$_in" = 0 ] && [ "$_line" = "Required by:" ]; then _in=1; continue; fi
        [ "$_in" = 1 ] && [ "$_line" = "" ] && _in=0
        [ "$_in" = 1 ] && printf '%s\n' "$_line"
    done
}
req_by() { pkg_info -f "$1" | grep '^@depend' | cut -f 3 -d :; }
get_orphans() {
    for _p in $(pkg_info -mz); do
        _p="${_p%--}"
        [ -z "$(req "$_p")" ] && printf '%s\n' "$_p"
    done
}
del() { doas pkg_delete "$1" && doas pkg_delete -a; }
alias add="doas pkg_add -Dsnap"
have ntpctl && alias chkclock="ntpctl -s all"
have systat && alias sensors="systat -s 1 sensors"
