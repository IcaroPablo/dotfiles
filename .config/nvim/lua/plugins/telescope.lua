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

        -- live_grep has no fallback without rg; find_files falls back to fd or find
        if vim.fn.executable("rg") == 0 then
            vim.notify("rg (ripgrep) não encontrado: <leader>g (live_grep) não funciona", vim.log.levels.WARN)
        end

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
                    require("telescope.themes").get_dropdown({}),
                },
            },
        })

        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("fzf")

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
    end,
}
