-- ════════════════════════════════════════════════════════════════════════════
--  shpad — o editor como linha de comando do shell
-- ════════════════════════════════════════════════════════════════════════════
--
-- Só no painel que o shpad abriu, que é onde a variável existe. Num nvim comum
-- as teclas não teriam para onde mandar, e sobrariam como teclas mortas.
if not vim.env.SHPAD_FIFO then
    return
end

local map = require("core.map")
local shpad = require("core.shpad")

-- Por `:` e não por <Cmd>: é a saída do modo visual que fixa as marcas `'<` e
-- `'>`, e é delas que a seleção é lida.
map.set("x", "<leader>R", ":lua require('core.shpad').run()<CR>")
map.set("n", "<leader>R", "<Cmd>lua require('core.shpad').run_paragraph()<CR>")

-- Ctrl+Enter roda o parágrafo sob o cursor sem sair do insert. Por <Cmd>, que
-- não troca de modo nem mexe no cursor. A Ghostty manda CSI 27;5;13~ para essa
-- tecla, o dvtm repassa byte a byte e o nvim decodifica como <C-CR> sozinho --
-- medido nas três pontas, nada precisou ser configurado no caminho.
map.set("i", "<C-CR>", "<Cmd>lua require('core.shpad').run_paragraph()<CR>")

shpad.watch()
