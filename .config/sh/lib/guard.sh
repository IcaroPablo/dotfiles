# lib/guard.sh — portable helpers shared by the interactive rc and the wizard.
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

# os_open <files...>: open each argument with the platform's file handler,
# detached from the shell. macOS uses `open`; elsewhere `xdg-open` (via setsid
# when available so it survives the terminal). Returns non-zero if no opener.
os_open() {
    case "$(uname)" in
        Darwin)
            open "$@"
            ;;
        *)
            if have xdg-open; then
                for _f in "$@"; do
                    if have setsid; then
                        setsid xdg-open "$_f" >/dev/null 2>&1 &
                    else
                        xdg-open "$_f" >/dev/null 2>&1 &
                    fi
                done
                unset _f
            else
                printf 'os_open: no opener found for %s\n' "$(uname)" >&2
                return 1
            fi
            ;;
    esac
}

# mimetype <file>: MIME type of <file> (e.g. "text/plain", "application/pdf",
# "inode/directory"), following symlinks. Uses `--mime-type` — the one form
# that works on macOS, Linux and OpenBSD alike (BSD `file -i` does not report
# MIME). Shared by openfile and preview.
mimetype() { file --mime-type -bL "$1" 2>/dev/null; }

# batorcat <file> [bat-args...]: show <file> with bat (first 100 lines) when
# available, otherwise cat. Shared by preview (and usable anywhere).
batorcat() {
    _bf="$1"
    shift
    if have bat; then
        bat --line-range=:100 "$_bf" "$@"
    else
        cat "$_bf"
    fi
}
