# plain sh. FreeBSD's (root's on Chimera; unlike dash, it has bind) knows
# \[ \] but leaves ${PWD} in PS1 unexpanded, so it needs \w; dash knows neither
case "$(command -V bind 2>/dev/null)" in
    *builtin*) _cwd='\w' _m1='\[' _m2='\]' ;;
esac
