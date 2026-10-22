# scripts

Utilitários avulsos. Cada um roda sozinho, com o que o sistema já tem — nenhum
depende da minha configuração de shell.

O que **precisa** dela (o `preview` do fzf, o `openfile` do navegador, o `bar` do
xinitrc, o `shpad` do nvim) não está aqui: mora nos dotfiles, em `.config/sh/bin`,
junto do `rc.sh` que os chama. A divisão é por dependência, não por gosto.

    make install     liga os scripts em ~/.local/bin
    make uninstall   remove só os links que apontam para cá
    make list        mostra o que seria instalado
    make doctor      o que estes scripts precisam, e o que falta

`PREFIX` muda o destino (`make install PREFIX=/usr/local`).

O install não atropela nada: se o nome já estiver ocupado por algo que não é
nosso, ele reclama, pula aquele e sai com erro no fim — os outros entram. Com
`FORCE=1` o que estava lá é deslocado para `$PREFIX/share/posix-shell-scripts-collection/displaced`,
com a data no nome, em vez de apagado. Fora do `bin` de propósito: diretório de
PATH não é lugar para guardar arquivo deslocado.

O uninstall varre o `bin` do prefixo atrás de link que aponte para este
repositório, em vez de percorrer a lista de scripts. Assim ele também recolhe o
link de um script que já foi apagado daqui — pela outra ordem esse link deixava
de ser enumerado e ficava para sempre. Arquivo comum, ou link para outro lugar,
ele não toca. O que tiver sido deslocado por um `FORCE=1` continua onde está: o
uninstall avisa, mas não restaura.

Isso não é zelo teórico. O `compress` daqui disputa o nome com o `compress(1)`
do POSIX, que várias distribuições instalam em `/usr/bin` — como o `~/.local/bin`
vem antes no PATH, o daqui ganha. Sombra, não estrago, mas com `PREFIX=/usr/local`
seria estrago.
