# fangorn: the OpenBSD VM, reached over ssh from shire's st; sourced by env.sh
# at login
# dvtm sends 24-bit colour only if the outer TERM has RGB; st-256color hasn't
case $TERM in st-256color) DVTM_OUTER_TERM=st-direct; export DVTM_OUTER_TERM ;; esac
