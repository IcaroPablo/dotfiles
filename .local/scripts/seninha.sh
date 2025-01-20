# list entries in directory stack
dirs() {
	typeset i=0
	typeset d="$PWD"
	typeset n="${#DIRSTACK[@]}"

	while (( i <= n )); do
		[ n -gt 0 ] && printf "%d\t" "$i"

		case "$d/" in
            ("$HOME"/*)
                printf "%s\n" "~${d#"${HOME}"}"
                ;;
            (*)
                printf "%s\n" "$d"
                ;;
		esac

		d="${DIRSTACK[$((i++))]}"
	done
}

# change directory
cd() {
	# NAME
	#      cd - change directory and manage directory stack
	#
	# SYNOPSIS
	#      cd path
	#      cd ....[/path]
	#      cd ..[word]
	#      cd -[123456789]
	#      cd -
	#      cd + [path...]
	#      cd +[123456789]
	#
	# DESCRIPTION
	#      The cd function overwrides the cd builtin command with a
	#      more powerful syntax.  The argument can be a directory or
	#      a regular file (in which case it is considered the
	#      directory which it resides in).  This function also sets
	#      the completion for the make(1) command according to the
	#      Makefile in the current directory, and prints the first
	#      few lines of a README, if it exists in the directory.
	#
	#      In the first form, changes directory to the given path.
	#
	#      In the second format (the argument begins with a certain
	#      number of dots), changes to a directory up in the
	#      hierarchy.  For example, 'cd ..' goes to the parent
	#      directory, 'cd ...' goes to the parent's parent
	#      directory, 'cd .../foo' goes to the directory foo in the
	#      parent's parent directory.
	#
	#      In the third form (the argument is two dots followed by a
	#      word), changes to the first directory up in the hierarchy
	#      containing a given word.  For example, if the current
	#      directory is '/home/user/tmp/foo/bar', running 'cd ..tmp'
	#      goes to '/home/user/tmp'.
	#
	#      In the fourth form (the argument is a hyphen before a
	#      number), changes to the N-th directory on the stack and
	#      removes it from the stack.  For example, 'cd -4' goes to
	#      the fourth directory on the stack.
	#
	#      In the fifth form (the argument is a single hyphen), goes
	#      to the previous directory.
	#
	#      In the sixth form (the first argument is a plus), adds
	#      the current directory (or the directories passed as next
	#      arguments) to the end of the directory stack.
	#
	#      In the seventh and final form (the argument is a plus
	#      before a number), moves the N-th directory on the stack
	#      to the beginning of the stack.  For example, 'cd +4'
	#      moves the fourth directory on the stack to its beginning.
	#
	#      The directory stack is printed after each invocation.
	#
	# SEE ALSO
	#      dirs

	if [ "$#" -eq 0 ]; then
		set -- "$HOME"
	elif [ "$#" -gt 1 ] && [ "$1" != "+" ]; then
		echo "$0: cd: improper argument" >&2
		return 1
	fi

	case "$1" in
        +)
            shift
            case "$#" in
                0)
                    set -A tmp -- "$PWD"
                    ;;
                *)
                    for i; do
                        typeset d="$( { command cd "$i" || { [ -e "$i" ] && command cd "$(dirname "$i")" ; } ; } >/dev/null 2>&1 && echo $PWD || echo "")"
                        [ -z "$d" ] && unset tmp && echo "$0: cd: $i: unknown file" >&2 && return 1
                        set -A tmp -- "${tmp[@]}" "$d"
                    done
            esac

            set -A DIRSTACK -- "${tmp[@]}" "${DIRSTACK[@]}"
            unset tmp

            dirs
            return
            ;;
        -)
            ;;
        +*[!0-9]*|-*[!0-9]*)
            return 1
            ;;
        +*)             # rotate entries
            typeset n=$(( ${1#"+"} - 1 ))
            [ -z "${DIRSTACK[$n]}" ] && return
            set -- "${DIRSTACK[$n]}"
            unset DIRSTACK[$n]
            set -A DIRSTACK -- "$PWD" "${DIRSTACK[@]}"
            ;;
        -*)             # remove entry
            typeset n=$(( ${1#"-"} - 1 ))
            [ -z "${DIRSTACK[$n]}" ] && return
            unset DIRSTACK[$n]
            set -A DIRSTACK -- "${DIRSTACK[@]}"
            dirs
            return
            ;;
        ..|../*)        # regular dot-dot directory
            ;;
        .+(.)?(/*))     # dot-dot-dot...
            typeset pre=${1%%/*}
            case "$1" in
            */*) typeset pos=${1#*/} ;;
            *)   typeset pos="" ;;
            esac
            typeset n=${#pre}
            set -- "$PWD"
            while (( n-- > 1 ))
            do
                case "$1" in
                /) break ;;
                *) set -- "$(dirname "$1")" ;;
                esac
            done
            set -- "$1/$pos"
            ;;
        ..*)            # dot-dot plus name
            set -- "${PWD%"${PWD##*"${1#".."}"}"}"
            ;;
	esac
	{
		command cd "$1" || {
			[ -e "$1" ] && command cd "$(dirname "$1")"
		}
	} >/dev/null 2>&1 || {
		echo "$0: cd: $1: unknown file" >&2 && return 1
	}

	complete make "" $(make -qp 2>/dev/null | sed -n '/^[A-Za-z][^ :]* *:/{s/\([^: ]*\).*/\1/p;}')
	dirs
	return 0
}

# colon separated list of directories used by the cd command
CDPATH=".:$HOME:$HOME/proj:$HOME/files"

# set prompt and window title
PS1='$(
	# set _cwd to $PWD, replacing $HOME with ~
	case "$PWD/" in
	("$HOME"/*)
		_cwd="~${PWD#"${HOME}"}"
		;;
	(*)
		_cwd="$PWD"
		;;
	esac

	# set _tty to the name of tty, trim any /dev/ at the beginning
	_tty=$(tty)
	_tty=${_tty#/dev/}

	# set _host to the host name of the machine
	# set _title to "$_cwd - $_tty"; prefix it with "$_host:" if I am not on my laptop
	if test -z "$SSH_CONNECTION"
	then
		_host=""
		_title="$_cwd - $_tty"
	else
		_host="$(hostname)"
		_title="$_host:$_cwd - $_tty"
	fi

	# set _color to red if we are root, or to white if we are a normal user
	if [ $(id -u) -eq 0 ]; then
		_color="1;31m"
	else
		_color="1m"
	fi

	# return prompt
	printf "\\\\[\e[0m\\\\]"                # clear formatting
	printf "\\\\[\e]0;%s\a\\\\]" "$_title"  # set window title
	printf "\n"                             # print blank line before prompt
	printf "\\\\[\e[%s\\\\]" "$_color"      # set color to red if root, white otherwise
	printf "%s ❯ " "$_host"                 # set left prompt
	printf "\\\\[\e[0m\\\\]"                # clear formatting
)'
