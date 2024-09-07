require("ibl").setup({
    -- ['indent.char'] = '▏',
    indent = {
        char = '▏'
    },
    scope = {
        enabled = false,
    },
    exclude = {
        filetypes = {'alpha', 'dashboard', 'help', 'neo-tree', 'lsp-installer', 'neo-tree-popup', 'mason', 'TelescopePrompt', 'man'},
        buftypes = {'terminal'}
    }
})

-- -- verificar instalação
-- require('indentmini').setup({
--     char = '▏', -- "'│' 
--     exclude = {'alpha', 'dashboard', 'help', 'neo-tree', 'lsp-installer', 'neo-tree-popup', 'mason', 'TelescopePrompt', 'man'}
-- })


-- -- :echo &ft
-- vim.cmd [[
--     let g:indentLine_char = '▏' "'│' 
--     let g:indentLine_showFirstIndentLevel = 1
--     let g:indentLine_first_char = '▏' "'│' 
--     "let g:indentLine_leadingSpaceEnabled = 1
--     "let g:indentLine_leadingSpaceChar = '·'
--     let g:indentLine_fileTypeExclude = ['alpha', 'dashboard', 'help', 'neo-tree', 'lsp-installer', 'neo-tree-popup', 'mason', 'TelescopePrompt', 'man']
-- ]]
