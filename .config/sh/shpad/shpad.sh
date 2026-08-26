# shpad - promove este painel a um shell do shpad e abre o editor ao lado.
#
# Sourced pelo rc.sh. É função e não script porque precisa dar `exec` no shell
# que chamou: trocar o shell do painel é o que põe o fifo no caminho da entrada
# dele, e um script só conseguiria trocar a si mesmo.
#
# O shell que sai daqui é novo -- mesmo painel, mesmo diretório, mesmo ambiente
# exportado, mas outro processo. Histórico em memória e variável não exportada
# ficam para trás. Não há como injetar no pty de um shell que já roda sem o
# dvtm no meio, e é justamente o que este desenho evita.

shpad() {
    if [ -z "$DVTM_CMD_FIFO" ]; then
        printf 'shpad: só funciona dentro do dvtm (DVTM_CMD_FIFO vazio)\n' >&2
        return 1
    fi

    SHPAD_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/sh/shpad"
    SHPAD_HISTORY="${SHPAD_HISTORY:-$HOME/.local/share/history.sh}"
    SHPAD_FIFO="${TMPDIR:-/tmp}/shpad.$$.fifo"

    if [ ! -x "$SHPAD_HOME/shpad-run" ]; then
        printf 'shpad: não compilado -- rode `make -C %s`\n' "$SHPAD_HOME" >&2
        return 1
    fi

    mkdir -p "$(dirname "$SHPAD_HISTORY")"
    [ -e "$SHPAD_HISTORY" ] || : > "$SHPAD_HISTORY"

    export SHPAD_HOME SHPAD_HISTORY SHPAD_FIFO

    # Os caminhos vão como argumento, não por variável: o painel que o dvtm cria
    # herda o ambiente DELE, não o desta função. O segundo argumento do `create`
    # é o título da janela -- sem ele viria o basename do comando inteiro.
    printf 'create "%s %s %s" shpad\n' \
        "$SHPAD_HOME/shpad-edit" "$SHPAD_FIFO" "$SHPAD_HISTORY" > "$DVTM_CMD_FIFO"

    # O fifo é criado pelo shpad-run, que também o remove ao sair. Nada aqui
    # precisa esperar por ele: o editor só o procura quando você manda algo.
    exec "$SHPAD_HOME/shpad-run" "$SHPAD_FIFO"
}
