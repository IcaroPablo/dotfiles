# helpers sourced by rc.sh and the scripts in bin/

: "${CLIPFILE:=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/nav-clipboard}"
export CLIPFILE

have() { command -v "$1" >/dev/null 2>&1; }

# without file: by extension, else text unless the first 4K have a NUL
mimetype() {
    if have file; then file --mime-type -bL "$1" 2>/dev/null; return; fi
    [ -e "$1" ] || return 1
    [ -d "$1" ] && { echo inode/directory; return; }
    [ -s "$1" ] || { echo inode/x-empty; return; }
    _mt_n=$(abspath "$1" | tr '[:upper:]' '[:lower:]')
    _mt_e=${_mt_n##*.}
    case "$_mt_n" in
        *.jpg|*.jpeg) echo image/jpeg ;;
        *.png|*.gif|*.bmp|*.tiff|*.webp) echo "image/$_mt_e" ;;
        *.djvu) echo image/vnd.djvu ;;
        *.pdf) echo application/pdf ;;
        *.epub) echo application/epub+zip ;;
        *.mp4|*.m4v|*.mkv|*.webm|*.mov|*.avi|*.wmv|*.flv|*.mpg|*.mpeg|*.ogv|*.3gp)
            echo "video/$_mt_e" ;;
        *.wav|*.mp3|*.flac|*.m4a|*.ogg|*.oga|*.opus) echo "audio/$_mt_e" ;;
        *)
            if [ "$(dd if="$1" bs=4096 count=1 2>/dev/null | tr -d '\000' | wc -c)" = \
                "$(dd if="$1" bs=4096 count=1 2>/dev/null | wc -c)" ]; then echo text/plain
            else echo application/octet-stream; fi ;;
    esac
    unset _mt_n _mt_e
}

# the terminal on stdin: rows cols, W and H in pixels (H: the rows above the
# status line, whole cells, as chafa adds no margin), cw ch per cell. st doesn't
# answer the CSI 14t/16t queries, but fills the pixels in TIOCGWINSZ, which
# stty doesn't show
termsize() {
    set -- $(python3 -c 'import fcntl,termios,struct
print(*struct.unpack("4H",fcntl.ioctl(0,termios.TIOCGWINSZ,bytes(8))))')
    rows=$1 cols=$2 W=$3
    cw=$(($3 / cols)) ch=$(($4 / rows))
    H=$(((rows - 1) * ch))
}

# without realpath or readlink -f: resolve the folder, keep the name
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
