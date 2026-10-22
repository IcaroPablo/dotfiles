# dotfiles — configs and scripts, linked into place by symlinks.
#
#   make install     links the SETS into ~/.config, $HOME and ~/.local/bin
#   make uninstall   removes only the links that point here
#   make list        shows what SETS would link
#   make doctor      the links, the shell block, and the tools SETS needs
#
# SETS="0 1" (default: all) picks the sets: 0 common, 1 shire, 2 fangorn; 1
# and 2 depend only on 0. install removes our links to what is outside them.
#
# POSIX make, so also bmake and OpenBSD's make: no wildcard, notdir, addprefix
# or CURDIR; lists come from shell globs and the root from `pwd`. `cd` here
# first, not `make -C`, which OpenBSD's make lacks. .xinitrc sits in $HOME
# because OpenBSD's startx reads only ~/.xinitrc.

HOME_DIR ?= $(HOME)
BINDIR ?= $(HOME_DIR)/.local/bin

# Displaced by FORCE=1. Outside ~/.config and the PATH on purpose: neither is a
# place for stale copies.
DISPLACED = $(HOME_DIR)/.local/share/dotfiles/displaced

SETS = 0 1 2
SET0 = .config/git .config/sh \
	bin/openfile bin/preview
SET1 = .config/ghostty .xinitrc \
	bin/backuphd bin/bar bin/chimera-setup \
	bin/fzfmenu bin/monitor \
	bin/pull-files bin/rec-gif bin/run-program bin/scrotocr \
	bin/wipe-ssd
SET2 = .config/nvim .config/spdfv .config/vis \
	bin/igsaved bin/launch_nvim bin/shpad bin/sixiv bin/spdfv

# Missing, these fail the doctor; the groups below only inform.
REQUIRED = git fzf eza file mktemp

# label:tools, one list per set
GROUPS0 = \
	"NÚCLEO (degradam, mas fazem falta; rc.sh):fd fdfind zoxide readlink realpath make lsof" \
	"ARQUIVO (compress, extract do rc.sh):tar gzip bzip2 xz zip unzip unrar 7z" \
	"PREVIEW (preview):chafa ffmpeg ffprobe w3m exiftool"
GROUPS1 = \
	"X11 (xinitrc, bar, fzfmenu, monitor, as teclas do smawm):xwallpaper xsetroot xset xrdb xmodmap setxkbmap xinput xrandr xdpyinfo smawm st scrot xclip xdg-open" \
	"IMAGEM E VÍDEO (rec-gif, scrotocr):ffmpeg slop tesseract mogrify" \
	"DISCO (backuphd, wipe-ssd):rsync doas cryptsetup lsof udisksctl blkdiscard sfdisk mkfs.ext4" \
	"CELULAR (pull-files):adb"
GROUPS2 = \
	"EDITOR (nvim, launch_nvim):nvim tree-sitter rg" \
	"SHPAD (dvtm, e o carapace completa no nvim):dvtm carapace" \
	"IMAGEM (sixiv, igsaved):ffmpeg ffprobe chafa python3 less" \
	"DOCUMENTO (spdfv):pdfinfo pdftoppm ddjvu djvused mutool magick convert chafa python3"

# $pick: what SETS links; warns about files in no set. dest: where a file links.
PICK = all=" $(SET0) $(SET1) $(SET2) "; \
	for s in .config/* .xinitrc bin/*; do \
		case "$$all" in *" $$s "*) ;; *) echo "  ? $$s is in no set" >&2 ;; esac; \
	done; \
	pick=; for k in $(SETS); do case $$k in \
		0) pick="$$pick $(SET0)" ;; 1) pick="$$pick $(SET1)" ;; 2) pick="$$pick $(SET2)" ;; \
		*) echo "no set $$k" >&2; exit 1 ;; \
	esac; done; \
	dest() { case $$1 in bin/*) echo "$(BINDIR)/`basename "$$1"`" ;; *) echo "$(HOME_DIR)/$$1" ;; esac; }

# every link of ours, wherever install may have put one
OURS = for d in "$(HOME_DIR)"/.config/* "$(HOME_DIR)"/.xinitrc "$(BINDIR)"/*; do \
		[ -L "$$d" ] || continue; t=`readlink "$$d"`; \
		case "$$t" in "$$src"/*) rel=`echo "$$t" | sed "s|^$$src/||"` ;; *) continue ;; esac

.PHONY: all install uninstall list doctor

all:
	@echo "make install | make uninstall | make list | make doctor   [SETS=\"0 1 2\"]"

doctor:
	@src=`pwd`; $(PICK); echo "dotfiles :: doctor (`uname`, sets $(SETS))"; echo ""; \
	printf 'links\n'; \
	for rel in $$pick; do \
		d=`dest "$$rel"`; \
		if [ "`readlink "$$d"`" = "$$src/$$rel" ]; then printf '  \342\234\223 %s\n' "$$rel"; \
		else printf '  \342\234\227 %s\n' "$$rel"; fi; \
	done; printf '\n'; \
	printf 'shell\n'; \
	if r=`$${SHELL:-/bin/sh} -i -c rc_loaded </dev/null 2>/dev/null | sed -n 's/.*\(rc\.sh loaded by\)/\1/p'`; [ -n "$$r" ]; then \
		printf '  \342\234\223 %s\n' "$$r"; \
	else printf '  \342\234\227 %s -i does not load rc.sh (ENV, see the README)\n' "$${SHELL:-/bin/sh}"; fi; \
	printf '\n'; \
	bad=0; printf 'OBRIGATÓRIO\n  '; \
	for t in $(REQUIRED); do \
		if command -v "$$t" >/dev/null 2>&1; then printf '\342\234\223 %s  ' "$$t"; \
		else printf '\342\234\227 %s  ' "$$t"; bad=1; fi; \
	done; printf '\n\n'; \
	show() { for g in "$$@"; do \
		printf '%s\n  ' "$${g%%:*}"; \
		for t in $${g#*:}; do \
			if command -v "$$t" >/dev/null 2>&1; then printf '\342\234\223 %s  ' "$$t"; \
			else printf '\342\234\227 %s  ' "$$t"; fi; \
		done; printf '\n\n'; \
	done; }; \
	for k in $(SETS); do \
		echo "== SET $$k"; echo ""; \
		case $$k in 0) show $(GROUPS0) ;; 1) show $(GROUPS1) ;; 2) show $(GROUPS2) ;; esac; \
	done; \
	if [ $$bad = 0 ]; then echo "obrigatórios presentes."; else echo "falta obrigatório."; fi; \
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
				echo "  ! $$rel: `echo "$$d" | sed "s|^$(HOME_DIR)|~|"` já existe e não é nosso (FORCE=1 para deslocar)"; \
				bad=1; continue; \
			fi; \
			mkdir -p "$(DISPLACED)" || { bad=1; continue; }; \
			flat=`echo "$$rel" | sed -e 's|^\.||' -e 's|/|_|g'`; \
			mv "$$d" "$(DISPLACED)/$$flat.`date +%Y%m%d%H%M%S`" || { bad=1; continue; }; \
			echo "  ~ $$rel (o que estava lá foi para $(DISPLACED))"; \
		fi; \
		mkdir -p "`dirname "$$d"`"; \
		ln -sfn "$$s" "$$d" && echo "  + $$rel"; \
	done; exit $$bad

# Scans the targets for links pointing here rather than walking the sets, so
# the link of a file already deleted from the repository goes too.
uninstall:
	@src=`pwd`; \
	$(OURS); \
		rm -f "$$d" && echo "  - $$rel"; \
	done; \
	if [ -d "$(DISPLACED)" ] && [ -n "`ls -A "$(DISPLACED)" 2>/dev/null`" ]; then \
		echo ""; \
		echo "  nota: `ls -A "$(DISPLACED)" | wc -l | tr -d ' '` arquivo(s) em $(DISPLACED)"; \
		echo "  foram deslocados por um FORCE=1 e não voltam sozinhos."; \
	fi

list:
	@$(PICK); for rel in $$pick; do echo "  $$rel -> `dest $$rel`"; done
