require("ibl").setup({
    indent = {
        char = "▏",
    },
    scope = {
        enabled = false,
    },
    exclude = {
        filetypes = {
            "dashboard",
            "help",
            "lsp-installer",
            "mason",
            "TelescopePrompt",
            "man",
        },
        buftypes = { "terminal" },
    },
})
