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
    _shpad_home="${XDG_CONFIG_HOME:-$HOME/.config}/sh/shpad"
    _shpad_hist="${SHPAD_HISTORY:-$HOME/.local/share/history.sh}"
    _shpad_fifo="${TMPDIR:-/tmp}/shpad.$$.fifo"

    if [ -z "$DVTM_CMD_FIFO" ]; then
        printf 'shpad: só funciona dentro do dvtm (DVTM_CMD_FIFO vazio)\n' >&2
        unset _shpad_home _shpad_hist _shpad_fifo
        return 1
    fi

    if [ ! -x "$_shpad_home/shpad-run" ]; then
        printf 'shpad: não compilado -- rode `make -C %s`\n' "$_shpad_home" >&2
        unset _shpad_home _shpad_hist _shpad_fifo
        return 1
    fi

    mkdir -p "${_shpad_hist%/*}"
    [ -e "$_shpad_hist" ] || : > "$_shpad_hist"

    # Um `env` inline e nada exportado: o painel que o dvtm cria herda o
    # ambiente DELE, não o desta função, então exportar aqui não chegaria a
    # lugar nenhum. O segundo argumento do create é o título da janela -- é ele
    # que evita o basename do comando inteiro, e era a única razão de existir um
    # script separado para abrir o editor.
    #
    # $EDITOR porque foi o que se pediu, mas a integração do <C-CR> é do lado do
    # nvim: com outro editor isto abre o histórico e nada mais.
    printf 'create "env SHPAD_FIFO=%s %s %s" shpad\n' \
        "$_shpad_fifo" "${EDITOR:-nvim}" "$_shpad_hist" > "$DVTM_CMD_FIFO"

    # O fifo é criado pelo shpad-run, que também o remove ao sair. Nada precisa
    # esperar por ele: o editor só o procura quando você manda algo.
    exec "$_shpad_home/shpad-run" "$_shpad_fifo"
}
