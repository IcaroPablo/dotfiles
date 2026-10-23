# what setup/<os> shares, sourced from next to it. The caller sets user (who
# gets the environment), home (theirs), ws (their ~/Workspace) and as_user
# (runs a command line as them)

# GitHub over ssh with a key it accepts; otherwise over https, or abort. Sets
# url, the prefix clone uses
github_url() {
	key=$home/.ssh/id_ed25519
	url=git@github.com:IcaroPablo
	# ssh -T exits 1 even when it logs in: what tells is GitHub's greeting
	case $([ -f "$key" ] && as_user "ssh -T -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new git@github.com 2>&1") in
	*"successfully authenticated"*) ;;
	*)
		[ -t 0 ] || { echo "GitHub doesn't take $key, and no terminal to ask about https" >&2; exit 1; }
		printf "GitHub doesn't take %s (missing or not added); clone over https or abort? [h/A] " "$key"
		read -r ans
		case $ans in
		[Hh]*) url=https://github.com/IcaroPablo ;;
		*) echo "aborted" >&2; exit 1 ;;
		esac
		;;
	esac
}

# clone repo [dir]: into $ws/dir (default: repo)
clone() {
	_d=$ws/${2:-$1}
	if [ ! -d "$_d" ]; then as_user "git clone $url/$1.git $_d"
	# an https clone moves to ssh once GitHub takes the key
	elif [ "${url#git@}" != "$url" ]; then as_user "git -C $_d remote set-url origin $url/$1.git"
	fi
}

# the shell entry block from the dotfiles README, once
profile_block() {
	grep -q icaro-dotfiles "$home/.profile" 2>/dev/null || as_user 'cat >> $HOME/.profile' <<'EOF'
# >>> icaro-dotfiles >>>
ENV="$HOME/.config/sh/rc.sh"; export ENV
. "$HOME/.config/sh/env.sh"
# <<< icaro-dotfiles <<<
EOF
}

in_list() { _x=$1; shift; for _w; do [ "$_w" = "$_x" ] && return 0; done; return 1; }

# leftovers title before wanted...: under title, what before lists and wanted
# doesn't, to show what was there and this script doesn't install
leftovers() {
	_t=$1 _b=$2; shift 2
	_e=$(for _p in $_b; do in_list "$_p" "$@" || echo "$_p"; done)
	[ -z "$_e" ] || printf '\n%s:\n%s\n' "$_t" "$_e"
}
