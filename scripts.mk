# scripts — utilitários avulsos: cada um roda sozinho, sem depender da minha
# configuração de shell. O que precisa dela mora nos dotfiles, em .config/sh/bin.
#
#   make install     liga os scripts em ~/.local/bin
#   make uninstall   remove só os links que apontam para cá
#   make list        mostra o que seria instalado
#
# SETS="0 1" (default: all) picks the sets; install removes our links to
# scripts outside them. 1 and 2 only depend on 0.
#
# São symlinks, não cópias: editar aqui vale na hora, sem reinstalar.
#
# POSIX make, e portanto também bmake e o make do OpenBSD: nada de wildcard,
# notdir, addprefix ou CURDIR, que são função do GNU make e não existem lá. As
# listas saem do shell, com glob, e a raiz sai de `pwd` — por isso `cd` no
# repositório antes, e não `make -C`, que o make do OpenBSD não tem.

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin

# Onde vai parar o que estava ocupando o nome, quando se instala com FORCE=1.
# Fora do BINDIR de propósito: diretório de PATH não é lugar para acumular
# arquivo deslocado — ficaria no caminho de busca e o uninstall não o levaria.
DISPLACED = $(PREFIX)/share/posix-shell-scripts-collection/displaced

SETS = 0 1 2
SET0 = bulkrename compress create delete extract findfile preview shredtrash \
	simplegrep trash
# shire
SET1 = backuphd chimera-setup fix_boot_entry \
	fzfmenu monitor pull-files rec_gif run-program scr_shot scrotocr wipe-ssd
# fangorn
SET2 = igsaved launch_nvim mount_encrypted sixiv spdfv umount_encrypted

# O que os scripts daqui chamam, e nada além disso: a configuração de shell tem
# as dependências dela, no doctor do repositório de dotfiles. Cada repositório
# responde pelo que o próprio código invoca.
REQUIRED = fzf mktemp

# label:ferramentas — o doctor percorre esta lista. Grupo opcional só informa;
# nenhum deles derruba o resultado, porque script que não se usa não faz falta.
# One list per set; doctor checks those in SETS.
GROUPS0 = \
	"ARQUIVO (compress, extract):tar gzip bzip2 xz zip unzip unrar 7z" \
	"BUSCA (findfile):fd fdfind" \
	"PREVIEW (preview):eza file chafa ffmpeg ffprobe w3m exiftool"
GROUPS1 = \
	"X11 (fzfmenu, run-program, monitor, scr_shot):xrandr xdpyinfo st scrot xclip" \
	"IMAGEM E VÍDEO (rec_gif, scrotocr):ffmpeg slop tesseract mogrify" \
	"DISCO (backuphd, wipe-ssd):rsync doas cryptsetup lsof udisksctl blkdiscard sfdisk mkfs.ext4" \
	"CELULAR (pull-files):adb" \
	"SISTEMA (fix_boot_entry):efibootmgr"
GROUPS2 = \
	"EDITOR (launch_nvim):nvim" \
	"IMAGEM (sixiv, igsaved):ffmpeg ffprobe chafa python3 less" \
	"DOCUMENTO (spdfv):pdfinfo pdftoppm ddjvu djvused mutool magick convert chafa python3" \
	"DISCO (mount_encrypted, umount_encrypted):doas bioctl"

.PHONY: all install uninstall list doctor

# the scripts in SETS; warns about scripts in no set
PICK = for n in `ls bin`; do \
		case " $(SET0) $(SET1) $(SET2) " in *" $$n "*) ;; *) echo "  ? $$n is in no set" >&2 ;; esac; \
	done; \
	pick=; for k in $(SETS); do case $$k in \
		0) pick="$$pick $(SET0)" ;; 1) pick="$$pick $(SET1)" ;; 2) pick="$$pick $(SET2)" ;; \
		*) echo "no set $$k" >&2; exit 1 ;; \
	esac; done

all:
	@echo "make install | make uninstall | make list | make doctor"

doctor:
	@echo "posix-shell-scripts-collection :: doctor (`uname`)"; echo ""; \
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
		case $$k in \
		0) show $(GROUPS0) ;; 1) show $(GROUPS1) ;; 2) show $(GROUPS2) ;; \
		*) echo "no set $$k" >&2; exit 1 ;; \
		esac; \
	done; \
	if [ $$bad = 0 ]; then echo "obrigatórios presentes."; else echo "falta obrigatório."; fi; \
	exit $$bad

# Não atropela o que já está lá. `ln -sf` sobrescreve calado, e o nome de um
# script avulso não é tão improvável quanto parece: o compress daqui já disputa
# com o compress(1) do POSIX. Conflito é reportado e a instalação segue nos
# outros; FORCE=1 desloca o ocupante, sem apagar.
install:
	@src="`pwd`/bin"; mkdir -p "$(BINDIR)"; bad=0; $(PICK); \
	for f in "$(BINDIR)"/*; do \
		[ -L "$$f" ] || continue; n=`basename "$$f"`; \
		case "`readlink "$$f"`" in "$$src"/*) ;; *) continue ;; esac; \
		case " $$pick " in *" $$n "*) ;; *) rm -f "$$f" && echo "  - $$n" ;; esac; \
	done; \
	for n in $$pick; do \
		s="$$src/$$n"; d="$(BINDIR)/$$n"; \
		if [ -L "$$d" ] && [ "`readlink "$$d"`" = "$$s" ]; then \
			echo "  = $$n"; continue; \
		fi; \
		if [ -e "$$d" ] || [ -L "$$d" ]; then \
			if [ -z "$(FORCE)" ]; then \
				echo "  ! $$n já existe e não é nosso (FORCE=1 para deslocar)"; \
				bad=1; continue; \
			fi; \
			mkdir -p "$(DISPLACED)" || { bad=1; continue; }; \
			mv "$$d" "$(DISPLACED)/$$n.`date +%Y%m%d%H%M%S`" || { bad=1; continue; }; \
			echo "  ~ $$n (o que estava lá foi para $(DISPLACED))"; \
		fi; \
		ln -sfn "$$s" "$$d" && echo "  + $$n"; \
	done; exit $$bad

# Varre o BINDIR atrás de link que aponte para cá, em vez de percorrer os
# scripts do repositório. A diferença aparece quando um script é apagado daqui:
# pela outra ordem o link instalado deixava de ser enumerado e ficava para
# sempre, quebrado, sem install nem uninstall voltarem a olhar para ele.
#
# Arquivo comum, ou link para outro lugar, continua intocado.
uninstall:
	@src="`pwd`/bin"; \
	for f in "$(BINDIR)"/*; do \
		[ -L "$$f" ] || continue; \
		t=`readlink "$$f"`; \
		case "$$t" in \
			"$$src"/*) rm -f "$$f" && echo "  - `basename "$$f"`" ;; \
		esac; \
	done; \
	if [ -d "$(DISPLACED)" ] && [ -n "`ls -A "$(DISPLACED)" 2>/dev/null`" ]; then \
		echo ""; \
		echo "  nota: `ls -A "$(DISPLACED)" | wc -l | tr -d ' '` arquivo(s) em $(DISPLACED)"; \
		echo "  foram deslocados por um FORCE=1 e não voltam sozinhos."; \
	fi

list:
	@$(PICK); for n in $$pick; do echo "  $$n"; done
