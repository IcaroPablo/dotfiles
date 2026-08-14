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
