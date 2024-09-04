-- verificar instalação

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
        "sql",
        "vim",
        "yaml"
    },
    highlight = { enable = true }
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
