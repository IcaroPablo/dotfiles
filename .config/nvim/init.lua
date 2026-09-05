--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

-- ── Statusline / mensagens ───────────────────────────────────────────────────
vim.opt.statusline = "%!v:lua.require'core.statusline'.render()"
vim.opt.showmode = false -- não mostra "-- INSERT --": a statusline já exibe o modo
vim.opt.showcmd = false -- não mostra o comando parcial no canto inferior direito

-- ── Aparência ────────────────────────────────────────────────────────────────
-- 24-bit só quando o terminal aceita -- o porquê da fonte está no core/term.lua.
-- Afirmar sempre pinta errado onde não dá: num tty o dvtm entrega colors#8 aos
-- painéis, e o nvim mandando RGB ali é aproximado na marra.
--
-- Em autocmd, e não só uma atribuição: o gruvbox.nvim liga termguicolors por
-- conta própria quando o colorscheme carrega (lua/gruvbox.lua:1379, sem opção
-- pra desligar), então qualquer valor posto aqui na largada é sobrescrito. Só
-- ele faz isso -- o retrobox, que entra no lugar dele quando não há truecolor,
-- lê a opção em vez de forçá-la (retrobox.vim:14).
local term = require("core.term")
vim.opt.termguicolors = term.truecolor()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("truecolor", { clear = true }),
    callback = function()
        vim.o.termguicolors = term.truecolor()
    end,
})

-- ── Números de linha ─────────────────────────────────────────────────────────
vim.opt.number = true -- números de linha
vim.opt.relativenumber = true -- números relativos à linha atual

-- ── Busca ────────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true -- busca ignora maiúsculas/minúsculas...
vim.opt.smartcase = true -- ...exceto quando você digita alguma maiúscula
-- vim.opt.incsearch = true -- redundante: já é o default (mostra a busca em tempo real)
-- vim.opt.hlsearch = false -- default é true (mantém o realce dos resultados de busca)

-- ── Indentação ───────────────────────────────────────────────────────────────
vim.opt.expandtab = true -- Tab insere espaços em vez de um caractere de tab
vim.opt.tabstop = 4 -- largura visual de um tab
vim.opt.softtabstop = 4 -- quantos espaços o Tab/Backspace contam na edição
vim.opt.shiftwidth = 4 -- largura da indentação (>>, <<, autoindent)
vim.opt.smartindent = true -- indent automático após blocos estilo C
vim.opt.shiftround = true
-- vim.opt.autoindent = true -- redundante: já é o default

-- ── Quebra de linha ──────────────────────────────────────────────────────────
-- vim.opt.wrap = true -- redundante: já é o default (quebra visual de linhas longas)

-- ── Splits ───────────────────────────────────────────────────────────────────
vim.opt.splitbelow = true -- split horizontal abre embaixo da janela atual
vim.opt.splitright = true -- split vertical abre à direita da janela atual
-- vim.opt.laststatus = 2

-- ── Rolagem ──────────────────────────────────────────────────────────────────
-- vim.opt.cursorline = true -- realça a linha do cursor (ver autocmd comentado abaixo)
vim.opt.scrolloff = 10 -- mantém 10 linhas de contexto acima/abaixo do cursor

-- ── Arquivos / persistência ──────────────────────────────────────────────────
vim.opt.swapfile = false -- sem arquivos de swap
vim.opt.undofile = true -- undo persiste entre sessões; o undodir default já é
-- o stdpath("state")/undo, então não precisa apontar à mão
-- vim.opt.undoreload = 10000 -- redundante: já é o default
-- vim.opt.history = 1000 -- comentado: o default do nvim (10000) é maior; sem motivo pra reduzir
vim.opt.updatetime = 2000 -- de quanto em quanto o CursorHold dispara (default é 4000)
-- vim.opt.shadafile = "NONE" -- desliga a persistência do shada (marks/registers/etc)
-- vim.opt.path:append("**") -- :find recursivo (a linha antiga era sintaxe vimscript, inválida em Lua)

-- ── Entrada / clipboard ──────────────────────────────────────────────────────
vim.opt.clipboard = "unnamedplus" -- usa o clipboard do sistema (registro +)
vim.opt.mouse = "a" -- pretend you didn't see this shit here
-- vim.opt.wildmenu = true -- redundante: já é o default (menu de autocompletar de :cmd)
-- vim.opt.errorbells = false -- redundante: já é o default (sem beep de erro)

vim.g.mapleader = " " -- tecla líder = espaço

-- Todo mapeamento da config passa pelo map.set. Vem depois do mapleader, pra
-- `<leader>` já resolver certo.
local map = require("core.map")

if not vim.loader.enabled then
    vim.loader.enable()
end

-- Mostra a cursorline só na janela ativa
-- vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
--     group = vim.api.nvim_create_augroup("cursor_active_window", { clear = true }),
--     callback = function(args)
--         vim.wo.cursorline = args.event == "WinEnter"
--     end,
-- })

-- vim.cmd([[
--     syntax on "some nice and fancy syntax highlight
--     filetype plugin on "auxiliates in filetype dependant behaviour
-- ]])

-- setting gruvbox as colorscheme in manpages also disable italics :)
-- vim.cmd([[
--     autocmd FileType man colorscheme gruvbox
-- ]])

-- vim.api.nvim_create_user_command("SetDotfilesGitVars", function()
--     vim.env.GIT_WORK_TREE = vim.fn.expand("~")
--     vim.env.GIT_DIR = vim.fn.expand("~/.config/dotfiles")
-- end, {})

-- vim.api.nvim_create_user_command("DisableLSPColors", function()
--     for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
--         vim.api.nvim_set_hl(0, group, {})
--     end
-- end, {})

-- cd global para a raiz do projeto. Comentado: o telescope passou a resolver a
-- raiz por buffer e o session-manager faz o próprio cd, então sobrou só o cwd
-- de :terminal, :! e caminhos relativos. Vira :tcd quando as abas virarem projeto.
-- local root = require("core.root")
--
-- vim.api.nvim_create_user_command("Dig", function()
--     local root_dir = root.project()
--
--     if root_dir ~= nil then
--         vim.cmd.cd(root_dir)
--     else
--         vim.notify("raiz do projeto não encontrada", vim.log.levels.WARN)
--     end
-- end, {})

-- Formata a config inteira com StyLua
vim.api.nvim_create_user_command("StyluaConfig", function()
    if vim.fn.executable("stylua") == 0 then
        vim.notify("stylua não encontrado no PATH", vim.log.levels.WARN)
        return
    end
    local out = vim.fn.system({ "stylua", vim.fn.stdpath("config") })
    if vim.v.shell_error ~= 0 then
        vim.notify(out, vim.log.levels.ERROR)
    else
        vim.cmd("checktime") -- recarrega buffers reformatados no disco
        vim.notify("StyLua: config formatada", vim.log.levels.INFO)
    end
end, {})

vim.api.nvim_create_user_command("MapCheck", function()
    local out = map.check()
    vim.notify(#out > 0 and table.concat(out, "\n") or "keymaps: sem choque")
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("map_check", { clear = true }),
    callback = function()
        vim.schedule(map.notify)
    end,
})

-- Salva a saída de :messages num arquivo (útil pra depurar)
vim.api.nvim_create_user_command("LogMessages", function()
    local path = vim.fn.expand("~/nvim_msgs.txt")
    vim.fn.writefile(vim.split(vim.fn.execute("messages"), "\n"), path)
    vim.notify("mensagens salvas em " .. path)
end, {})

-- ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
-- ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
-- ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
-- ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
-- ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
-- ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝

require("core.pack").setup()

-- ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║╚════██║
-- ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝███████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

-- easily manage buffers
map.set("n", "<Tab>", ":bnext<CR>:redraw<CR>")
map.set("n", "<S-Tab>", ":bprevious<CR>:redraw<CR>")

-- Fecha janela/buffer de forma "inteligente": se o buffer está aberto em várias
-- janelas, fecha só esta janela; senão remove o buffer.
map.set("n", "<leader>q", function()
    local buf = vim.api.nvim_get_current_buf()
    local wins_in_tab = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
    local wins_with_buf = #vim.fn.win_findbuf(buf)
    if wins_in_tab > 1 and wins_with_buf > 1 then
        vim.cmd("close")
    else
        vim.cmd("bdelete!")
    end
end)

map.set("n", "<leader>n", ":enew | startinsert<CR>") -- New file
map.set("n", "<leader>C", ":e $HOME/.config/nvim/init.lua<CR>") -- Configs

-- Painel do dvtm carregando o socket desta sessão: o launch_nvim de lá roteia os
-- arquivos de volta pra cá em vez de abrir um nvim aninhado.
local function dvtm_pane(dir)
    local fifo = vim.env.DVTM_CMD_FIFO
    if not fifo then
        return vim.notify("sem DVTM_CMD_FIFO: o dvtm precisa do -c", vim.log.levels.WARN)
    end
    local f = io.open(fifo, "a")
    if not f then
        return vim.notify("não abriu " .. fifo, vim.log.levels.ERROR)
    end
    f:write(('create "INITIAL_FOLDER=%s NVIM=%s exec $SHELL"\n'):format(dir, vim.v.servername))
    f:close()
end

map.set("n", "<leader>t", function()
    dvtm_pane(vim.fn.expand("%:p:h"))
end)

map.set("n", "<leader>T", function()
    dvtm_pane(require("core.root").dir() or vim.fn.expand("%:p:h"))
end)

-- map("n", "<A-<>", "<cmd>BufferMovePrevious<CR>", { silent = true, noremap = true })
-- map("n", "<A->>", "<cmd>BufferMoveNext<CR>", { silent = true, noremap = true })
-- map("n", "<A-1>", "<cmd>BufferGoto 1<CR>", { silent = true, noremap = true })
-- map("n", "<A-2>", "<cmd>BufferGoto 2<CR>", { silent = true, noremap = true })
-- map("n", "<A-3>", "<cmd>BufferGoto 3<CR>", { silent = true, noremap = true })
-- map("n", "<A-4>", "<cmd>BufferGoto 4<CR>", { silent = true, noremap = true })
-- map("n", "<A-5>", "<cmd>BufferGoto 5<CR>", { silent = true, noremap = true })
-- map("n", "<A-6>", "<cmd>BufferGoto 6<CR>", { silent = true, noremap = true })
-- map("n", "<A-7>", "<cmd>BufferGoto 7<CR>", { silent = true, noremap = true })
-- map("n", "<A-8>", "<cmd>BufferGoto 8<CR>", { silent = true, noremap = true })
-- map("n", "<A-9>", "<cmd>BufferLast<CR>", { silent = true, noremap = true })
-- map("n", "<A-t>", "<cmd>BufferPin<CR>", { silent = true, noremap = true })
-- map("n", "<A-c>", "<cmd>BufferClose<CR>", { silent = true, noremap = true })
-- map("n", "<A-u>", "<cmd>BufferPick<CR>", { silent = true, noremap = true })

-- easily manage windows
-- vim.keymap.set("", "<c-j>", "<c-w>j", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-k>", "<c-w>k", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-h>", "<c-w>h", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-l>", "<c-w>l", { noremap = true, silent = true })

-- vim.keymap.set("", "<c-up>", "<c-w>+", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-down>", "<c-w>-", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-left>", "<c-w>>", { noremap = true, silent = true })
-- vim.keymap.set("", "<c-right>", "<c-w><", { noremap = true, silent = true })

map.set("", "<c-h>", "<c-w>>")
map.set("", "<c-k>", "<c-w>+")
map.set("", "<c-j>", "<c-w>-")
map.set("", "<c-l>", "<c-w><")

-- move lines up and down using alt key
map.set("n", "<A-j>", ":m .+1<CR>==")
map.set("n", "<A-k>", ":m .-2<CR>==")
map.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
map.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
map.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
map.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- navigate quickfixes
map.set("n", "<c-p>", ":cprev<CR>zz")
map.set("n", "<c-n>", ":cnext<CR>zz")

-- center search results
-- vim.keymap.set("n", "n", "nzz", {noremap = true, silent = true})
-- vim.keymap.set("n", "N", "Nzz", {noremap = true, silent = true})
map.set("n", "<C-d>", "<C-d>zz")
map.set("n", "<C-u>", "<C-u>zz")
map.set("n", "<C-o>", "<C-o>zz")
map.set("n", "<C-i>", "<C-i>zz")
-- vim.keymap.set("n", "#", "#zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g*", "g*zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g#", "g#zz", { silent = true, noremap = true })
map.set("n", "<leader>w", "*N")
map.set("x", "<leader>p", [["_dP]])
-- vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- deactivate space because of annoying behaviour since its my leader key :)
map.set("n", "<Space>", "<Nop>")

-- word substitution
-- vim.keymap.set("n", "<C-j>", "ciw<C-r>0<ESC>", {silent = true})
-- vim.keymap.set("n", "<C-s>", '"1yiwciw<C-r>0<ESC>/<C-r>1<CR>', { silent = true })
-- vim.keymap.set("n", "<Leader>jq", ":%!jq '.'<CR>", { silent = true })

-- other niceties
map.set("v", "<", "<gv")
map.set("v", ">", ">gv")
map.set("n", "<Leader><Leader>", ":write<CR>")
map.set("n", "<c-[>", "<esc>:nohlsearch<CR>")
