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
            "TelescopePrompt",
            "man",
        },
        buftypes = { "terminal" },
    },
})
