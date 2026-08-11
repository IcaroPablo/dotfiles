# os.d/darwin.sh — macOS-specific env + interactive bits. Sourced by env.sh.
# _path_prepend() and have() are already defined (env.sh / guard.sh).

# Homebrew on PATH (Apple Silicon first, then Intel), without duplicating.
for _b in /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin /usr/local/sbin; do
    [ -d "$_b" ] && _path_prepend "$_b"
done
unset _b
export PATH

# Terminal launcher for split_scr / nvim term integration. There is no `st`
# on macOS; wire it to a known terminal if present, otherwise leave it unset
# (split_scr degrades to a no-op rather than erroring).
if have wezterm; then
    TERM_CMD='wezterm start --'
    NVIM_TERM_CMD='wezterm start --'
    export TERM_CMD NVIM_TERM_CMD
fi
