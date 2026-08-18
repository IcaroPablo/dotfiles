local map = require("core.map")

return {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("gitsigns").setup({
            -- dotfiles em bare repo: o gitsigns não descobre o repo sozinho
            worktrees = {
                { toplevel = vim.env.HOME, gitdir = vim.env.HOME .. "/.config/dotfiles" },
            },
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local opts = { buffer = bufnr }

                map.set("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gs.nav_hunk("next")
                    end
                end, opts)

                map.set("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gs.nav_hunk("prev")
                    end
                end, opts)

                map.set("n", "<leader>hr", gs.reset_hunk, opts)
                map.set("n", "<leader>hR", gs.reset_buffer, opts)
                map.set("n", "<leader>hp", gs.preview_hunk, opts)
                map.set("n", "<leader>hi", gs.preview_hunk_inline, opts)

                map.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", opts)
            end,
        })
    end,
}
