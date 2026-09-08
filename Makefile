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

HOME_DIR ?= $(HOME)
SRC      := $(CURDIR)

# Deslocados por FORCE=1. Fora do ~/.config de propósito: ferramenta que varre o
# próprio diretório de configuração não deve topar com cópia velha lá dentro.
DISPLACED := $(HOME_DIR)/.local/share/dotfiles/displaced

# A árvore é a lista — diretório novo em .config/ entra sozinho, sem manifesto.
# O .xinitrc é à parte porque o startx do OpenBSD só lê o ~/.xinitrc, nunca o
# $XDG_CONFIG_HOME/xinitrc.
LINKS := $(addprefix .config/,$(notdir $(wildcard $(SRC)/.config/*))) .xinitrc

.PHONY: install uninstall list

# Não atropela o que já está lá: o alvo é o ~/.config de verdade, e apagar a
# configuração alheia do nvim é bem pior do que sombrear um comando.
install:
	@bad=0; for rel in $(LINKS); do \
		s=$(SRC)/$$rel; d=$(HOME_DIR)/$$rel; \
		if [ -L "$$d" ] && [ "`readlink $$d`" = "$$s" ]; then \
			echo "  = $$rel"; continue; \
		fi; \
		if [ -e "$$d" ] || [ -L "$$d" ]; then \
			if [ -z "$(FORCE)" ]; then \
				echo "  ! $$rel já existe e não é nosso (FORCE=1 para deslocar)"; \
				bad=1; continue; \
			fi; \
			mkdir -p $(DISPLACED) || { bad=1; continue; }; \
			mv "$$d" "$(DISPLACED)/`echo $$rel | tr / _`.`date +%Y%m%d%H%M%S`" || { bad=1; continue; }; \
			echo "  ~ $$rel (o que estava lá foi para $(DISPLACED))"; \
		fi; \
		mkdir -p "`dirname $$d`"; \
		ln -sfn "$$s" "$$d" && echo "  + $$rel"; \
	done; exit $$bad

# Varre os destinos atrás de link que aponte para cá, em vez de percorrer a
# lista: assim o link de um diretório que já saiu do repositório sai junto.
uninstall:
	@for d in $(HOME_DIR)/.config/* $(HOME_DIR)/.xinitrc; do \
		[ -L "$$d" ] || continue; \
		case "`readlink $$d`" in \
			$(SRC)/*) rm -f "$$d" && echo "  - `basename $$d`" ;; \
		esac; \
	done
	@if [ -d $(DISPLACED) ] && [ -n "`ls -A $(DISPLACED) 2>/dev/null`" ]; then \
		echo ""; \
		echo "  nota: `ls -A $(DISPLACED) | wc -l | tr -d ' '` arquivo(s) em $(DISPLACED)"; \
		echo "  foram deslocados por um FORCE=1 e não voltam sozinhos."; \
	fi

list:
	@for rel in $(LINKS); do echo "  $$rel"; done
