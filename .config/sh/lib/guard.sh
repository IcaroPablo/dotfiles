# lib/guard.sh — portable helpers shared by rc.sh and openfile.
# POSIX sh. Meant to be sourced, not executed. Safe to source more than once.

: "${CLIPFILE:=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/nav-clipboard}"
export CLIPFILE

# have <cmd>: succeed if <cmd> is an executable in PATH (or a shell builtin).
have() { command -v "$1" >/dev/null 2>&1; }

# abspath <path>: print the absolute, symlink-resolved path of <path>.
# Prefers realpath / `readlink -f` when present; falls back to a POSIX method
# that resolves the directory and keeps the basename (BSD without -f).
abspath() {
    if have realpath; then
        realpath "$1" 2>/dev/null && return 0
    fi
    if readlink -f / >/dev/null 2>&1; then
        readlink -f "$1" 2>/dev/null && return 0
    fi
    _ap_dir=$(dirname -- "$1")
    _ap_base=$(basename -- "$1")
    if _ap_dir=$(CDPATH= cd -- "$_ap_dir" 2>/dev/null && pwd -P); then
        case "$_ap_base" in
            /) printf '%s\n' "/" ;;
            .) printf '%s\n' "$_ap_dir" ;;
            *) printf '%s\n' "${_ap_dir%/}/$_ap_base" ;;
        esac
    else
        printf '%s\n' "$1"
    fi
    unset _ap_dir _ap_base
}
