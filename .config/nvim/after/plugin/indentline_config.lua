require("ibl").setup({
    -- indent = {
    --     char = '▏'
    -- },
    scope = {
        enabled = false,
    },
    exclude = {
        filetypes = {
            "alpha",
            "dashboard",
            "help",
            "neo-tree",
            "lsp-installer",
            "neo-tree-popup",
            "mason",
            "TelescopePrompt",
            "man",
        },
        buftypes = { "terminal" },
    },
})
