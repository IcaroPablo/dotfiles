vim.keymap.set("n", "<leader>do", ":DiffviewOpen --selected-file=%<CR>", {noremap = true, silent = true});
vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", {noremap = true, silent = true});
vim.keymap.set("n", "<leader>fh", ":DiffviewFileHistory %<CR>", {noremap = true, silent = true});
