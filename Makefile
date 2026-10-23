# dotfiles — configs and scripts, linked into place by symlinks.
#
#   make install     links what MANIFEST gives this machine into ~/.config,
#                    $HOME and ~/.local/bin, and removes our other links
#   make uninstall   removes only the links that point here
#   make list        shows what this machine gets, and what it doesn't and why
#   make doctor      the links, whether rc.sh loads, and the declared capabilities
#
# What this machine gets comes from the capabilities setup/<os> declared in
# CAPSFILE. Only declared capabilities are checked, and install stops, linking
# nothing, if one of them fails its check.
#
# POSIX make, so also bmake and OpenBSD's make: no wildcard, notdir, addprefix
# or CURDIR; lists come from shell globs and the root from `pwd`. `cd` here
# first, not `make -C`, which OpenBSD's make lacks. .xinitrc sits in $HOME
# because OpenBSD's startx reads only ~/.xinitrc.

HOME_DIR ?= $(HOME)
BINDIR ?= $(HOME_DIR)/.local/bin

# the capabilities setup/<os> installed and declared here, this machine's only
CAPSFILE = $(HOME_DIR)/.config/dotfiles/capabilities

# Displaced by FORCE=1. Outside ~/.config and the PATH on purpose: neither is a
# place for stale copies.
DISPLACED = $(HOME_DIR)/.local/share/dotfiles/displaced

# what each capability needs to be there, when declared: commands, or /paths
# for what puts none on the PATH; a|b is either one. sixel can't be checked in
# the terminal, only in the viewers' tools: the rest is trusted
CHECKS = \
	"x11:startx xrandr xsetroot xdpyinfo xclip st smawm scrot slop" \
	"sixel:chafa ffmpeg ffprobe python3 pdfinfo pdftoppm djvused ddjvu" \
	"text-editing:nvim tree-sitter rg vis" \
	"dvtm:dvtm" \
	"phone:adb" \
	"host:rsync cryptsetup|bioctl" \
	"ocr:tesseract mogrify" \
	"yt-dlp:yt-dlp" \
	"ghostty:ghostty|/Applications/Ghostty.app"

# $decl: what's declared; $failed: "cap (missing: x y);" per declared one that
# fails its check; $pick: what this machine links; $skip: "path: no need;".
# Stops on a missing CAPSFILE or a name nobody knows. dest: where a file links.
PICK = os=`uname | tr '[:upper:]' '[:lower:]'`; [ "$$os" != darwin ] || os=macos; \
	[ -f "$(CAPSFILE)" ] || { echo "no $(CAPSFILE): run setup/<os>, or list this machine's capabilities in it (empty: none)" >&2; exit 1; }; \
	decl=`cat "$(CAPSFILE)"`; decl=`echo $$decl`; \
	known=; for c in $(CHECKS); do known="$$known $${c%%:*}"; done; \
	for c in $$decl; do case " $$known " in *" $$c "*) ;; *) echo "$(CAPSFILE): no capability $$c (known:$$known)" >&2; exit 1 ;; esac; done; \
	there() { case $$1 in /*) [ -e "$$1" ] ;; *) command -v "$$1" >/dev/null 2>&1 ;; esac; }; \
	missing() { for w in $$1; do o=; for a in `echo "$$w" | tr '|' ' '`; do there "$$a" && { o=1; break; }; done; \
		[ -n "$$o" ] || printf '%s ' "$$w"; done; }; \
	failed=; for c in $(CHECKS); do n=$${c%%:*}; case " $$decl " in *" $$n "*) ;; *) continue ;; esac; \
		m=`missing "$${c\#*:}"`; [ -z "$$m" ] || failed="$$failed$$n (missing: $${m% });"; done; \
	caps=" $$os $$decl "; \
	unmet() { for w in $$1; do o=; for a in `echo "$$w" | tr '|' ' '`; do \
		case "$$caps" in *" $$a "*) o=1; break ;; esac; done; [ -n "$$o" ] || { echo "$$w"; return; }; done; }; \
	all=' ' pick= skip=; \
	while IFS=: read -r p n; do \
		case $$p in '\#'*|'') continue ;; esac; set -- $$p; p=$$1; all="$$all$$p "; \
		for w in `echo "$$n" | tr '|' ' '`; do case " $$known linux openbsd macos " in *" $$w "*) ;; \
			*) echo "MANIFEST: $$p needs $$w, which is neither a capability nor an OS" >&2; exit 1 ;; esac; done; \
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
	@echo "make install | make uninstall | make list | make doctor"

list:
	@$(PICK); echo "$$os: `echo $$decl`"; \
	printf '%s' "$$failed" | tr ';' '\n' | sed 's/^/  ! not fully there: /'; \
	for rel in $$pick; do echo "  $$rel -> `dest $$rel`"; done; \
	printf '%s' "$$skip" | tr ';' '\n' | sed 's/^/  . /'

doctor:
	@src=`pwd`; $(PICK); echo "dotfiles :: doctor ($$os: `echo $$decl`)"; echo ""; \
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
	printf '\ncapabilities\n'; \
	for c in $(CHECKS); do n=$${c%%:*}; case " $$decl " in *" $$n "*) ;; *) continue ;; esac; \
		printf '  %s\n    ' "$$n"; \
		for w in $${c#*:}; do o=; for a in `echo "$$w" | tr '|' ' '`; do there "$$a" && { o=1; break; }; done; \
			if [ -n "$$o" ]; then printf '\342\234\223 %s  ' "$$w"; else printf '\342\234\227 %s  ' "$$w"; bad=1; fi; \
		done; printf '\n'; \
	done; \
	if [ -n "$$skip" ]; then printf '\nnot for this machine\n'; printf '%s' "$$skip" | tr ';' '\n' | sed 's/^/  /'; fi; \
	exit $$bad

# Doesn't trample what's there: the target is the real ~/.config, and a clash
# is reported and skipped.
# FORCE=1 displaces the occupant, dated, instead of deleting it.
install:
	@src=`pwd`; bad=0; $(PICK); \
	if [ -n "$$failed" ]; then \
		printf '%s' "$$failed" | tr ';' '\n' | sed 's/^/  ! declared but not fully there: /' >&2; \
		echo "  nothing linked: install what's missing (setup/<os>), or undeclare it in $(CAPSFILE)" >&2; exit 1; \
	fi; \
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
