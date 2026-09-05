-- alternativa (mantida em comentário): gruvbox-community/gruvbox (o community é vimscript)
-- {
--     "gruvbox-community/gruvbox",
--     lazy = false,
--     priority = 1000,
--     init = function()
--         vim.g.gruvbox_bold = "0"
--         vim.g.gruvbox_contrast_dark = "hard"
--     end,
--     config = function()
--         vim.cmd([[ colorscheme gruvbox ]])
--     end,
-- },
return {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        -- Sem truecolor o gruvbox.nvim não tem o que mandar: ele define só
        -- atributos gui, zero ctermfg/ctermbg em grupo nenhum, então o buffer
        -- inteiro sairia na cor default do terminal -- não é degradação pras 16
        -- cores, é ausência de cor. Quem degrada é o retrobox, que vem com o
        -- nvim e define as duas paletas: Comment sai ctermfg=102 / fg=#928374,
        -- exatamente o mesmo RGB que o gruvbox.nvim usa. Ele também respeita o
        -- termguicolors em vez de forçá-lo (retrobox.vim:14), então basta a
        -- opção já estar resolvida aqui -- e está: o init.lua a define antes de
        -- o pack carregar os plugins.
        if not require("core.term").truecolor() then
            vim.cmd("colorscheme retrobox")
            return
        end

        require("gruvbox").setup({
            terminal_colors = true,
            undercurl = false,
            underline = false,
            bold = false,
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                operators = false,
                folds = false,
            },
            strikethrough = true,
            invert_selection = true,
            invert_signs = true,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = false,
            contrast = "hard", -- "hard", "soft" ou ""
            dim_inactive = false,
            transparent_mode = false,
        })
        vim.cmd("colorscheme gruvbox")
    end,
}
