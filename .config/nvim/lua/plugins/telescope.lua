local map = require("core.map")

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-tree/nvim-web-devicons",
        -- nice to have: telescope-file-browser, telescope-frecency, telescope-zoxide, telescope-dict
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "command -v gmake >/dev/null 2>&1 && gmake || make",
        },
    },
    config = function()
        local root = require("core.root")

        require("telescope").setup({
            defaults = {
                path_display = {
                    shorten = {
                        len = 3,
                        exclude = { 1, -1 },
                    },
                    truncate = true,
                },
                dynamic_preview_title = true,
            },
            extensions = {
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case", -- or 'ignore_case' or 'respect_case'
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({
                        -- even more opts
                    }),
                },
                -- pseudo code / specification for writing custom displays, like the one
                -- for 'codeactions'
                -- specific_opts = {
                --   [kind] = {
                --     make_indexed = function(items) -> indexed_items, width,
                --     make_displayer = function(widths) -> displayer
                --     make_display = function(displayer) -> function(e)
                --     make_ordinal = function(e) -> string
                --   },
                --   -- for example to disable the custom builtin 'codeactions' display
                --      do the following
                --   codeactions = false,
                -- }
            },
        })

        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("fzf")
        -- require('telescope').load_extension('frecency')

        -- map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>gb", "<cmd>Telescope git_bcommits<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { silent = true, noremap = true })
        map.set("n", "<leader><Tab>", require("telescope.builtin").buffers)
        map.set("n", "<leader>o", require("telescope.builtin").oldfiles)
        map.set("n", "<leader>f", function()
            require("telescope.builtin").find_files({ hidden = true, cwd = root.dir() })
        end)
        map.set("n", "<leader>s", function()
            require("telescope.builtin").git_files({ hidden = true, cwd = root.dir() })
        end)
        map.set("n", "<leader>g", function()
            require("telescope.builtin").live_grep({ hidden = true, cwd = root.dir() })
        end)
        map.set("n", "<leader>d", function()
            require("telescope.builtin").diagnostics({ severity_bound = 0 })
        end)
        -- nnoremap("<leader>fm", "<cmd>Telescope marks<cr>", "Find mark")
        -- nnoremap("<leader>fr", "<cmd>Telescope lsp_references<cr>", "Find references (LSP)")
        -- nnoremap("<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", "Find symbols (LSP)")
        -- nnoremap("<leader>fc", "<cmd>Telescope lsp_incoming_calls<cr>", "Find incoming calls (LSP)")
        -- nnoremap("<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>", "Find outgoing calls (LSP)")
        -- nnoremap("<leader>fi", "<cmd>Telescope lsp_implementations<cr>", "Find implementations (LSP)")
        -- nnoremap("<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>", "Find errors (LSP)")
        -- map("n", "<leader>h", "<cmd>Telescope oldfiles<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>j", "<cmd>Telescope resume<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>k", "<cmd>Telescope zoxide list<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>m", "<cmd>Telescope man_pages<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>n", "<cmd>Telescope builtin<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>qc", "<cmd>Telescope lsp_code_actions<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>sf", "<cmd>Telescope spell_suggests<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>t", ":lua require('telescope').extensions.dict.synonyms()<CR>", { silent = true, noremap = true })
        -- map("n", "<leader>;", "<cmd>Telescope keymaps<CR>", { silent = true, noremap = true })
    end,
}
