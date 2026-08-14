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
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        require("gitsigns").nav_hunk("next")
                    end
                end)

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        require("gitsigns").nav_hunk("prev")
                    end
                end)

                map("n", "<leader>hr", require("gitsigns").reset_hunk)
                map("n", "<leader>hR", require("gitsigns").reset_buffer)
                map("n", "<leader>hp", require("gitsigns").preview_hunk)
                map("n", "<leader>td", require("gitsigns").preview_hunk_inline)

                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
            end,
        })
    end,
}
