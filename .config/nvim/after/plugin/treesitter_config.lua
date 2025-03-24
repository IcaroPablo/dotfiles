require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "elixir",
        "graphql",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "ron",
        "sql",
        "vim",
        "yaml"
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true
    },
    modules = {},
    ignore_install = {}
    -- indent = { enable = true }
    -- autotag = {
    --         enable = true,
    --         filetypes = {
    --                 "html",
    --                 "javascript",
    --                 "javascriptreact",
    --                 "svelte",
    --                 "typescript",
    --                 "typescriptreact",
    --                 "vue",
    --                 "xml"
    --             },
    --         },
})
