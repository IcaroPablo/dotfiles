#!/bin/sh
# desmontar o hd criptografado

# echo "$(whoami)"

# [ "$UID" -eq 0 ] || exec doas "$0" "$@"

# fazer desse script um toggle ?
doas umount /mnt/secretstuff
doas bioctl -d sd3
