local_copy="/mnt/secretstuff/" # drive in which i write stuff
mirror="/mnt/sd3i/" # drive from which i only read stuff

rsync -Dlrtv --size-only $local_copy $mirror
