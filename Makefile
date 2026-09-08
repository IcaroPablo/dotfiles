# dotfiles — a configuração ligada à máquina por symlinks.
#
#   make install     liga em ~/.config e no $HOME
#   make uninstall   remove só os links que apontam para cá
#   make list        mostra o que seria ligado
#
# São symlinks, não cópias: o que uma ferramenta escreve na própria config — o
# nvim-pack-lock.json, por exemplo — cai dentro do repositório e aparece no
# `git status`, sem passo de sincronia nenhum.
#
# O bloco do shell não entra aqui. São duas linhas no ~/.profile, estão no
# README, e injetar texto em arquivo alheio é o que um Makefile faz pior.
#
# POSIX make, e portanto também bmake e o make do OpenBSD: nada de wildcard,
# notdir, addprefix ou CURDIR, que são função do GNU make e não existem lá. As
# listas saem do shell, com glob, e a raiz sai de `pwd` — por isso `cd` no
# repositório antes, e não `make -C`, que o make do OpenBSD não tem.
#
# A lista é a árvore: diretório novo em .config/ entra sozinho, sem manifesto.
# O .xinitrc é à parte porque o startx do OpenBSD só lê o ~/.xinitrc, nunca o
# $XDG_CONFIG_HOME/xinitrc.

HOME_DIR ?= $(HOME)

# Deslocados por FORCE=1. Fora do ~/.config de propósito: ferramenta que varre o
# próprio diretório de configuração não deve topar com cópia velha lá dentro.
DISPLACED = $(HOME_DIR)/.local/share/dotfiles/displaced

# O que esta configuração chama, e nada além disso: os utilitários avulsos têm
# as dependências deles, no doctor do repositório da coleção. Cada repositório
# responde pelo que o próprio código invoca.
REQUIRED = git nvim fzf eza bat file mktemp dvtm tree-sitter

# label:ferramentas. Grupo opcional só informa; nada aqui derruba o resultado.
# O create e o monitor são da coleção, mas entram porque é este código que os
# chama: o nvim abre painel com o create, o xinitrc arruma a tela com o monitor.
GROUPS = \
	"NÚCLEO (degradam, mas fazem falta):fd fdfind zoxide readlink realpath make lsof carapace" \
	"PREVIEW (opcional):w3m exiftool unzip tar pixterm" \
	"X11 (só na máquina gráfica):feh xsetroot xset xrdb xmodmap setxkbmap xinput smawm" \
	"COLEÇÃO (outro repositório):create monitor"

.PHONY: all install uninstall list doctor

all:
	@echo "make install | make uninstall | make list | make doctor"

doctor:
	@src=`pwd`; echo "dotfiles :: doctor (`uname`)"; echo ""; \
	printf 'symlinks\n'; \
	for s in "$$src"/.config/* "$$src"/.xinitrc; do \
		rel=$${s#$$src/}; d="$(HOME_DIR)/$$rel"; \
		if [ -L "$$d" ] && [ "`readlink "$$d"`" = "$$s" ]; then \
			printf '  \342\234\223 %s\n' "$$rel"; \
		else printf '  \342\234\227 %s\n' "$$rel"; fi; \
	done; printf '\n'; \
	printf 'shell\n'; found=0; \
	for f in "$(HOME_DIR)/.profile" "$(HOME_DIR)/.zprofile" "$(HOME_DIR)/.bash_profile"; do \
		[ -f "$$f" ] || continue; \
		if grep -q 'config/sh/env.sh' "$$f" 2>/dev/null; then \
			printf '  \342\234\223 %s carrega o env.sh\n' "$$f"; found=1; \
		fi; \
	done; \
	[ $$found = 1 ] || printf '  \342\234\227 nenhum profile carrega o ~/.config/sh/env.sh\n'; \
	printf '\n'; \
	bad=0; printf 'OBRIGATÓRIO\n  '; \
	for t in $(REQUIRED); do \
		if command -v "$$t" >/dev/null 2>&1; then printf '\342\234\223 %s  ' "$$t"; \
		else printf '\342\234\227 %s  ' "$$t"; bad=1; fi; \
	done; printf '\n\n'; \
	for g in $(GROUPS); do \
		printf '%s\n  ' "$${g%%:*}"; \
		for t in $${g#*:}; do \
			if command -v "$$t" >/dev/null 2>&1; then printf '\342\234\223 %s  ' "$$t"; \
			else printf '\342\234\227 %s  ' "$$t"; fi; \
		done; printf '\n\n'; \
	done; \
	if [ $$bad = 0 ]; then echo "obrigatórios presentes."; else echo "falta obrigatório."; fi; \
	exit $$bad

# Não atropela o que já está lá: o alvo é o ~/.config de verdade, e apagar a
# configuração alheia do nvim é bem pior do que sombrear um comando.
install:
	@src=`pwd`; bad=0; \
	for s in "$$src"/.config/* "$$src"/.xinitrc; do \
		rel=$${s#$$src/}; d="$(HOME_DIR)/$$rel"; \
		if [ -L "$$d" ] && [ "`readlink "$$d"`" = "$$s" ]; then \
			echo "  = $$rel"; continue; \
		fi; \
		if [ -e "$$d" ] || [ -L "$$d" ]; then \
			if [ -z "$(FORCE)" ]; then \
				echo "  ! $$rel já existe e não é nosso (FORCE=1 para deslocar)"; \
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

# Varre os destinos atrás de link que aponte para cá, em vez de percorrer a
# lista: assim o link de um diretório que já saiu do repositório sai junto.
uninstall:
	@src=`pwd`; \
	for d in "$(HOME_DIR)"/.config/* "$(HOME_DIR)"/.xinitrc; do \
		[ -L "$$d" ] || continue; \
		t=`readlink "$$d"`; \
		case "$$t" in \
			"$$src"/*) rm -f "$$d" && echo "  - `basename "$$d"`" ;; \
		esac; \
	done; \
	if [ -d "$(DISPLACED)" ] && [ -n "`ls -A "$(DISPLACED)" 2>/dev/null`" ]; then \
		echo ""; \
		echo "  nota: `ls -A "$(DISPLACED)" | wc -l | tr -d ' '` arquivo(s) em $(DISPLACED)"; \
		echo "  foram deslocados por um FORCE=1 e não voltam sozinhos."; \
	fi

list:
	@for s in .config/* .xinitrc; do echo "  $$s"; done
