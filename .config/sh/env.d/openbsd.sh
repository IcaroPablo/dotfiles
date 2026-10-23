# OpenBSD, sourced by env.sh while _path_prepend still exists
export AUDIOPLAYDEVICE="snd/0" AUDIORECDEVICE="snd/1"      # sndio
# the newest of the jdk-NN packages
if [ -z "${JAVA_HOME:-}" ]; then
    for _j in /usr/local/jdk-*; do [ -d "$_j" ] && JAVA_HOME=$_j; done
    unset _j
fi
[ -n "${JAVA_HOME:-}" ] && export JAVA_HOME && _path_prepend "$JAVA_HOME/bin"
_path_prepend /usr/X11R6/bin
_path_prepend /usr/games
