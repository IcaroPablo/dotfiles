
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
vim.opt.history = 1000              -- sometimes i wanna undo many steps
vim.opt.wildmenu = true             -- useful for autocompletion
-- vim.opt.clipboard = vim.opt.clipboard + "unnamedplus"   -- uses the + register (aka the system clipboard) as vim clipboard 
vim.cmd [[set clipboard+=unnamedplus]]
vim.cmd [[set t_md=]]
vim.opt.mouse = "a"                 -- pretend you didn't see this shit here
vim.g.mapleader = ' '
-- vim.loader.enable()

-- This allows you to undo changes to a file even after saving it.
vim.cmd([[
    if version >= 703
        set undodir=~/.vim/backup
        set undofile
        set undoreload=10000
    endif
]])

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
            bp | sp | bn | bd!
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
require('mappings').setup_basic_mappings()
