# terminal helpers for the sixel viewers; sourced after core.sh

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
