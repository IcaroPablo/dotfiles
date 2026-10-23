# dotfiles — configs and scripts, linked into place by symlinks.
#
#   make install     links what MANIFEST gives this machine into ~/.config,
#                    $HOME and ~/.local/bin, and removes our other links
#   make uninstall   removes only the links that point here
#   make list        shows what this machine gets, and what it doesn't and why
#   make doctor      the links, whether rc.sh loads, and the tools each one uses
#
# The machine is `hostname -s`, or HOST=name; its .config/sh/hosts/<name>.sh
# gives its tags. With no such file, only what needs no host tags is linked.
#
# POSIX make, so also bmake and OpenBSD's make: no wildcard, notdir, addprefix
# or CURDIR; lists come from shell globs and the root from `pwd`. `cd` here
# first, not `make -C`, which OpenBSD's make lacks. .xinitrc sits in $HOME
# because OpenBSD's startx reads only ~/.xinitrc.

HOME_DIR ?= $(HOME)
BINDIR ?= $(HOME_DIR)/.local/bin
HOST = `hostname -s 2>/dev/null || hostname`

# Displaced by FORCE=1. Outside ~/.config and the PATH on purpose: neither is a
# place for stale copies.
DISPLACED = $(HOME_DIR)/.local/share/dotfiles/displaced

# what a host file can say a machine has; the OS tag comes from uname
TAGS = host x11 sixel linux openbsd macos

# $pick: what this machine links; $skip: "path: no need;" for what it doesn't.
# Warns about files MANIFEST doesn't list. dest: where a file links.
PICK = host=$(HOST); host=$${host%%.*}; \
	os=`uname | tr '[:upper:]' '[:lower:]'`; [ "$$os" != darwin ] || os=macos; \
	hf=.config/sh/hosts/$$host.sh; has=; \
	if [ -f "$$hf" ]; then has=`sh -c '. "./$$1" >/dev/null 2>&1; printf %s "$$HAS"' sh "$$hf"`; \
	else echo "  note: no $$hf, so only what needs no host tags" >&2; fi; \
	caps=" $$os $$has "; \
	met() { case " $(TAGS) " in *" $$1 "*) case "$$caps" in *" $$1 "*) return 0 ;; esac; return 1 ;; esac; \
		command -v "$$1" >/dev/null 2>&1; }; \
	unmet() { for w in $$1; do o=; for a in `echo "$$w" | tr '|' ' '`; do met "$$a" && { o=1; break; }; done; \
		[ -n "$$o" ] || { echo "$$w"; return; }; done; }; \
	all=' ' pick= skip=; \
	while IFS=: read -r p n u; do \
		case $$p in '\#'*|'') continue ;; esac; set -- $$p; p=$$1; all="$$all$$p "; \
		w=`unmet "$$n"`; if [ -z "$$w" ]; then pick="$$pick $$p"; else skip="$$skip$$p: no $$w;"; fi; \
	done < MANIFEST; \
	for s in .config/* .xinitrc bin/*; do \
		case "$$all" in *" $$s "*) ;; *) echo "  ? $$s is not in MANIFEST" >&2 ;; esac; \
	done; \
	dest() { case $$1 in bin/*) echo "$(BINDIR)/`basename "$$1"`" ;; *) echo "$(HOME_DIR)/$$1" ;; esac; }

# every link of ours, wherever install may have put one
OURS = for d in "$(HOME_DIR)"/.config/* "$(HOME_DIR)"/.xinitrc "$(BINDIR)"/*; do \
		[ -L "$$d" ] || continue; t=`readlink "$$d"`; \
		case "$$t" in "$$src"/*) rel=`echo "$$t" | sed "s|^$$src/||"` ;; *) continue ;; esac

.PHONY: all install uninstall list doctor

all:
	@echo "make install | make uninstall | make list | make doctor   [HOST=name]"

list:
	@$(PICK); echo "$$host: `echo $$caps`"; \
	for rel in $$pick; do echo "  $$rel -> `dest $$rel`"; done; \
	printf '%s' "$$skip" | tr ';' '\n' | sed 's/^/  . /'

doctor:
	@src=`pwd`; $(PICK); echo "dotfiles :: doctor ($$host: `echo $$caps`)"; echo ""; \
	bad=0; printf 'links\n'; \
	for rel in $$pick; do \
		d=`dest "$$rel"`; \
		if [ "`readlink "$$d"`" = "$$src/$$rel" ]; then printf '  \342\234\223 %s\n' "$$rel"; \
		else printf '  \342\234\227 %s\n' "$$rel"; bad=1; fi; \
	done; printf '\n'; \
	printf 'shell\n'; \
	if r=`$${SHELL:-/bin/sh} -i -c rc_loaded </dev/null 2>/dev/null | sed -n 's/.*\(rc\.sh loaded by\)/\1/p'`; [ -n "$$r" ]; then \
		printf '  \342\234\223 %s\n' "$$r"; \
	else printf '  \342\234\227 %s -i does not load rc.sh (ENV, see the README)\n' "$${SHELL:-/bin/sh}"; fi; \
	printf '\ntools\n'; \
	while IFS=: read -r p n u; do \
		case $$p in '#'*|'') continue ;; esac; set -- $$p; p=$$1; \
		case " $$pick " in *" $$p "*) ;; *) continue ;; esac; [ -n "`echo $$u`" ] || continue; \
		printf '  %s\n    ' "$$p"; \
		for w in $$u; do o=; for a in `echo "$$w" | tr '|' ' '`; do met "$$a" && { o=1; break; }; done; \
			if [ -n "$$o" ]; then printf '\342\234\223 %s  ' "$$w"; else printf '\342\234\227 %s  ' "$$w"; fi; \
		done; printf '\n'; \
	done < MANIFEST; \
	if [ -n "$$skip" ]; then printf '\nnot for this machine\n'; printf '%s' "$$skip" | tr ';' '\n' | sed 's/^/  /'; fi; \
	exit $$bad

# Doesn't trample what's there: the target is the real ~/.config, and a clash
# is reported and skipped.
# FORCE=1 displaces the occupant, dated, instead of deleting it.
install:
	@src=`pwd`; bad=0; $(PICK); \
	$(OURS); \
		case " $$pick " in *" $$rel "*) ;; *) rm -f "$$d" && echo "  - $$rel" ;; esac; \
	done; \
	for rel in $$pick; do \
		s="$$src/$$rel"; d=`dest "$$rel"`; \
		if [ -L "$$d" ] && [ "`readlink "$$d"`" = "$$s" ]; then \
			echo "  = $$rel"; continue; \
		fi; \
		if [ -e "$$d" ] || [ -L "$$d" ]; then \
			if [ -z "$(FORCE)" ]; then \
				echo "  ! $$rel: `echo "$$d" | sed "s|^$(HOME_DIR)|~|"` already exists and is not ours (FORCE=1 to displace it)"; \
				bad=1; continue; \
			fi; \
			mkdir -p "$(DISPLACED)" || { bad=1; continue; }; \
			flat=`echo "$$rel" | sed -e 's|^\.||' -e 's|/|_|g'`; \
			mv "$$d" "$(DISPLACED)/$$flat.`date +%Y%m%d%H%M%S`" || { bad=1; continue; }; \
			echo "  ~ $$rel (what was there moved to $(DISPLACED))"; \
		fi; \
		mkdir -p "`dirname "$$d"`"; \
		ln -sfn "$$s" "$$d" && echo "  + $$rel"; \
	done; \
	printf '%s' "$$skip" | tr ';' '\n' | sed 's/^/  . /'; \
	exit $$bad

# Scans the targets for links pointing here rather than walking MANIFEST, so
# the link of a file already deleted from the repository goes too.
uninstall:
	@src=`pwd`; \
	$(OURS); \
		rm -f "$$d" && echo "  - $$rel"; \
	done; \
	if [ -d "$(DISPLACED)" ] && [ -n "`ls -A "$(DISPLACED)" 2>/dev/null`" ]; then \
		echo ""; \
		echo "  note: `ls -A "$(DISPLACED)" | wc -l | tr -d ' '` file(s) in $(DISPLACED)"; \
		echo "  were displaced by a FORCE=1 and don't come back by themselves."; \
	fi
