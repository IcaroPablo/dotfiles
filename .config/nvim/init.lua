
--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 

vim.opt.laststatus = 2              -- last window will always have a status line (?)
-- vim.opt.statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}
vim.opt.showmode = false            -- the status bar already shows the current mode
vim.opt.showcmd = false             -- don't really remember :)

vim.opt.autoindent = true           -- self-describing
vim.opt.smartindent = true          -- inserts an automatic indent after common C-like expressions or keywords

vim.opt.errorbells = false          -- self-describing
vim.opt.wrap = true                 -- wrap lines

vim.opt.smartcase = true            -- searches are case sensitive only if uppercase is used
vim.opt.ignorecase = true           -- has to be set for smartcase to work properly

-- vim.opt.hlsearch = false            -- remove highlights from search
vim.opt.incsearch = true            -- search results are showed in real time

vim.opt.number = true               -- numbered lines
vim.opt.relativenumber = true       -- numbered lines are now relative to the current line
vim.opt.cursorline = true           -- display the current line

vim.opt.expandtab = true            -- uses tabs instead of spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.splitbelow = true           -- horizontal split goes below the current window
vim.opt.splitright = true           -- vertical split goes right of the current window

vim.opt.termguicolors = true        -- uses true color
vim.opt.swapfile = false            -- self-describing
-- vim.opt.updatetime = 50
-- vim.opt.shadafile = "NONE"
vim.opt.scrolloff = 10              -- offvim.opt.for scrolling
-- vim.opt.path += **                  -- useful for :find

vim.opt.history = 1000
vim.opt.undodir = vim.fn.expand('~/.vim/backup')
vim.opt.undofile = true
vim.opt.undoreload = 10000

vim.opt.wildmenu = true             -- useful for autocompletion
vim.opt.clipboard = "unnamedplus"   -- uses the + register (aka the system clipboard) as vim clipboard 
vim.opt.mouse = "a"                 -- pretend you didn't see this shit here

vim.g.mapleader = ' '

if (not vim.loader.enabled) then
    vim.loader.enable()
end

-- Displays cursorline ONLY in active window.
vim.cmd([[
    augroup cursor_off
        autocmd!
        autocmd WinLeave * set nocursorline
        autocmd WinEnter * set cursorline
    augroup END
]])

-- Easily close windows and buffers
vim.cmd ([[
    function! EasyClose()
        if &modified
            write
        endif
        if tabpagewinnr(tabpagenr(), '$') > 1 " more than 1 window open ?
            if len(win_findbuf(bufnr('%'))) == 1 "current buffer is open in just one window ?
                bd!
                return
            endif
            close
            return
        endif
            "bp | sp | bn | bd!
            bd
    endfunction
]])

-- vim.cmd([[
--     syntax on "some nice and fancy syntax highlight
--     filetype plugin on "auxiliates in filetype dependant behaviour
-- ]])

-- setting gruvbox as colorscheme in manpages also disable italics :)
vim.cmd([[
    autocmd FileType man colorscheme gruvbox
]])

vim.api.nvim_create_user_command('SetDotfilesGitVars', function()
    vim.env.GIT_WORK_TREE = vim.fn.expand("~")
    vim.env.GIT_DIR = vim.fn.expand("~/.config/dotfiles")
end, {})

vim.api.nvim_create_user_command('DisableLSPColors', function()
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
      vim.api.nvim_set_hl(0, group, {})
    end
end, {})

vim.api.nvim_create_user_command('Dig', function()
    local root_dir = require('utils').get_root()

    if(root_dir ~= nil) then
        vim.cmd('cd ' .. root_dir)
    else
        print('root not found')
    end
end, {})

require('plugins')

-- easily manage buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>:redraw<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>:redraw<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":call EasyClose()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>Q", ":quit!<CR>", { noremap = true, silent = true })
-- map("n", "<A-<>", "<cmd>BufferMovePrevious<CR>", { silent = true, noremap = true })
-- map("n", "<A->>", "<cmd>BufferMoveNext<CR>", { silent = true, noremap = true })
-- map("n", "<A-1>", "<cmd>BufferGoto 1<CR>", { silent = true, noremap = true })
-- map("n", "<A-2>", "<cmd>BufferGoto 2<CR>", { silent = true, noremap = true })
-- map("n", "<A-3>", "<cmd>BufferGoto 3<CR>", { silent = true, noremap = true })
-- map("n", "<A-4>", "<cmd>BufferGoto 4<CR>", { silent = true, noremap = true })
-- map("n", "<A-5>", "<cmd>BufferGoto 5<CR>", { silent = true, noremap = true })
-- map("n", "<A-6>", "<cmd>BufferGoto 6<CR>", { silent = true, noremap = true })
-- map("n", "<A-7>", "<cmd>BufferGoto 7<CR>", { silent = true, noremap = true })
-- map("n", "<A-8>", "<cmd>BufferGoto 8<CR>", { silent = true, noremap = true })
-- map("n", "<A-9>", "<cmd>BufferLast<CR>", { silent = true, noremap = true })
-- map("n", "<A-t>", "<cmd>BufferPin<CR>", { silent = true, noremap = true })
-- map("n", "<A-c>", "<cmd>BufferClose<CR>", { silent = true, noremap = true })
-- map("n", "<A-u>", "<cmd>BufferPick<CR>", { silent = true, noremap = true })

-- easily manage windows
vim.keymap.set("", "<c-j>", "<c-w>j", { noremap = true, silent = true })
vim.keymap.set("", "<c-k>", "<c-w>k", { noremap = true, silent = true })
vim.keymap.set("", "<c-h>", "<c-w>h", { noremap = true, silent = true })
vim.keymap.set("", "<c-l>", "<c-w>l" ,{ noremap = true, silent = true })

vim.keymap.set("", "<c-up>", "<c-w>+", { noremap = true, silent = true })
vim.keymap.set("", "<c-down>", "<c-w>-", { noremap = true, silent = true })
vim.keymap.set("", "<c-left>", "<c-w>>", { noremap = true, silent = true })
vim.keymap.set("", "<c-right>", "<c-w><", { noremap = true, silent = true })

-- move lines up and down using alt key
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- utils
vim.keymap.set("n", "TT", function() require('utils').open_terminal_in(vim.fn.expand('%:p:h')) end, { noremap = true, silent = true })
vim.keymap.set("n", "tt", require('utils').open_terminal_in_project_root, { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>", require('lf_integration').reveal, {noremap = true, silent = true})

-- navigate quickfixes
vim.keymap.set("n", "<c-p>", ":cprev<CR>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-n>", ":cnext<CR>zz", { noremap = true, silent = true })

-- center search results
-- vim.keymap.set("n", "n", "nzz", {noremap = true, silent = true})
-- vim.keymap.set("n", "N", "Nzz", {noremap = true, silent = true})
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- vim.keymap.set("n", "#", "#zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g*", "g*zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g#", "g#zz", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>w", "*N", { silent = true, noremap = true })
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- deactivate space because of annoying behaviour since its my leader key :)
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true})

-- word substitution
-- vim.keymap.set("n", "<C-j>", "ciw<C-r>0<ESC>", {silent = true})
vim.keymap.set("n", "<C-s>", "\"1yiwciw<C-r>0<ESC>/<C-r>1<CR>", {silent = true})
vim.keymap.set("n", "<Leader>jq", ":%!jq '.'<CR>", {silent = true})

-- other niceties
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
vim.keymap.set("n", "<Leader><Leader>", ":write<CR>", {noremap = true, silent = true})
vim.keymap.set("n", "<c-[>", "<esc>:nohlsearch<CR>", {silent = true})
