# fangorn: the OpenBSD VM, reached over ssh from shire's sixel st. HAS is read
# by make; the rest is sourced by env.sh at login
HAS='sixel'
# dvtm sends 24-bit colour only if the outer TERM has RGB; st-256color hasn't
case $TERM in st-256color) DVTM_OUTER_TERM=st-direct; export DVTM_OUTER_TERM ;; esac
