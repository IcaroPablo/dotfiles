
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

vim.opt.expandtab = true            -- uses tabs instead of spaces
vim.opt.autoindent = true           -- self-describing
vim.opt.smartindent = true          -- inserts an automatic indent after common C-like expressions or keywords

vim.opt.errorbells = false          -- self-describing
vim.opt.wrap = true                 -- prevent lines from wrapping

vim.opt.smartcase = true            -- searches are case sensitive only if uppercase is used
vim.opt.ignorecase = true           -- has to be set for smartcase to work properly

vim.opt.hlsearch = false            -- remove highlights from search
vim.opt.incsearch = true            -- search results are showed in real time

vim.opt.number = true               -- numbered lines
vim.opt.relativenumber = true       -- numbered lines are now relative to the current line
vim.opt.cursorline = true           -- display the current line

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.splitbelow = true           -- horizontal split goes below the current window
vim.opt.splitright = true           -- vertical split goes right of the current window

vim.opt.termguicolors = true        -- uses true color
vim.opt.swapfile = false            -- self-describing
vim.opt.scrolloff = 10              -- offvim.opt.for scrolling
-- vim.opt.path += **                  -- useful for :find
vim.opt.history = 1000              -- sometimes i wanna undo many steps
vim.opt.wildmenu = true             -- useful for autocompletion
-- vim.opt.clipboard = vim.opt.clipboard + "unnamedplus"   -- uses the + register (aka the system clipboard) as vim clipboard 
vim.cmd [[set clipboard+=unnamedplus]]
vim.cmd [[set t_md=]]
vim.opt.mouse = "a"                 -- pretend you didn't see this shit here
-- vim.opt.shadafile = "NONE"

vim.g.mapleader = ' '

-- local set = vim.opt
-- set.background = "light"
-- set.autochdir = true
-- set.updatetime = 180
-- set.modeline = true
-- set.cursorline = true
-- set.cursorlineopt = "number"
-- set.synmaxcol = 400
-- set.colorcolumn = "99999"
-- set.hidden = true
-- set.showmode = false
-- set.showcmd = false
-- set.lazyredraw = true
-- set.ttyfast = true
-- set.conceallevel = 2
-- set.termguicolors = true
-- set.showtabline = 2
-- set.laststatus = 2
-- set.ruler = false
-- set.foldmethod = "syntax"
-- set.foldminlines = 1
-- set.foldnestmax = 6
-- set.foldenable = true
-- set.foldlevelstart = 1
-- set.foldcolumn = "0"
-- set.wrap = true
-- set.scrolljump = 1
-- set.wrapmargin = 0
-- set.textwidth = 0
-- set.formatoptions = set.formatoptions - "cro"
-- set.linebreak = true
-- set.mouse = "a"
-- set.undofile = true
-- set.number = true
-- set.relativenumber = false
-- set.splitbelow = true
-- set.splitright = true
-- set.timeoutlen = 400
-- set.ttimeout = true
-- set.ttimeoutlen = 10
-- set.hlsearch = true
-- set.ignorecase = true
-- set.incsearch = true
-- set.smartcase = true
-- set.tabstop = 4
-- set.shiftwidth = 4
-- set.softtabstop = 4
-- set.expandtab = true
-- set.smarttab = true
-- set.autoindent = true
-- set.backspace = { "indent", "eol", "start" }
-- set.clipboard = "unnamedplus"
-- set.sidescrolloff = 5
-- set.scrolloff = 1
-- set.history = 1000
-- vim.cmd([[set spell spelllang=en_gb]])
-- set.spell = false
-- set.encoding = "utf-8"
-- set.list = true
-- vim.cmd([[set fillchars+=eob:\ ,vert:│,foldopen:▾,foldclose:▸,foldsep:│,fold:\ ,diff:╱]])
-- vim.cmd([[set listchars=tab:<->,extends:›,precedes:‹,nbsp:∩,eol:¶,trail:×,lead:\ ,space:·,multispace:···+]])
-- set.showbreak = '↳'
-- set.completeopt = {'menu', 'menuone', 'noselect'}
-- set.shortmess = set.shortmess + "OoSsatTcI"
-- set.swapfile = false
-- set.path = set.path + "**"
-- vim.cmd([[filetype plugin on]])
-- vim.g['vimsyn_embed'] = 'l'
-- vim.g['tex_flavor'] = 'latex'
-- vim.g['tex_fold_enabled'] = '1'
-- vim.g['tex_conceal'] = 'abdgms'
-- vim.cmd([[let &titlestring = 'nvim ' ". expand("%:t")]])
-- set.title = true

-- " :.config/nvim/init.vim
-- " vim:set fdm=marker foldenable:
-- "
-- " IMPORT PLUGINS AND DISABLE SOME {{{
-- lua require'impatient'
-- lua require'plugins'
-- lua << EOF
-- local disabled_built_ins = {
--     "netrw",
--     "gzip",
--     "zip",
--     "netrwPlugin",
--     "netrwSettings",
--     "tar",
--     "tarPlugin",
--     "netrwFileHandlers",
--     "zipPlugin",
--     "getscript",
--     "getscriptPlugin",
--     "vimball",
--     "vimballPlugin",
--     "2html_plugin",
--     "logipat",
--     "spellfile_plugin",
--     "matchit",
-- }
-- for _, plugin in pairs(disabled_built_ins) do
--     vim.g["loaded_" .. plugin] = 1
-- end
-- EOF
-- " }}}
-- " COLORSCHEME {{{
-- colorscheme despair
-- " }}}
-- " COMMANDS {{{
-- " Wipe register {{{
-- command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor
-- " }}}
-- " }}}
-- " AUTO-COMMANDS {{{
-- " Reload snippets after editing {{{
-- augroup nvimcmp
--     autocmd!
--     autocmd BufWritePost *.snippets :CmpUltisnipsReloadSnippets
-- " }}}
-- " Alpha options {{{
-- augroup alpha
--     autocmd!
--     autocmd User AlphaReady set laststatus=0 | set showtabline=0 | set nofoldenable | autocmd BufUnload <buffer> set showtabline=2 | set laststatus=2
--     autocmd WinEnter,BufRead,BufNewFile * if &ft != 'alpha' | call CleanEmptyBuffers() | endif
-- augroup END
-- function! CleanEmptyBuffers()
--     let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val)<0 && !getbufvar(v:val, "&mod")')
--     if !empty(buffers)
--         exe 'bw ' . join(buffers, ' ')
--     endif
-- endfunction
-- " }}}
-- " Open a file where it was left off {{{
-- augroup stay
--     autocmd!
--     if has('autocmd')
--         autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
--                     \| exe "normal! g'\"" | endif
--     endif
-- augroup END
-- " }}}
-- " Stop autocommenting! {{{
-- augroup editing
--     autocmd!
--     autocmd BufEnter * setlocal formatoptions-=cro
-- augroup END
-- " }}}
-- " Close Outline if it's the only window left {{{
-- augroup Outline
--     autocmd!
--     autocmd BufEnter * if (winnr("$") == 1 && &filetype =~# 'Outline') | q | endif
-- augroup END
-- " }}}
-- " Highlight yanked {{{
-- augroup highlight_yank
--     autocmd!
--     autocmd TextYankPost * silent! lua vim.highlight.on_yank{"IncSearch", 1000}
-- augroup END
-- " }}}
-- " Set filetypes {{{
-- augroup filetypes
--     autocmd!
--     " Rasi extension is css-based
--     autocmd BufReadPost *.rasi set filetype=css
--     " Jupyter Notebook
--     autocmd BufReadPost *.ipynb set filetype=python
--     " .conf files
--     autocmd BufReadPost *.conf set filetype=config
-- augroup END
-- " }}}
-- " Autosource init.vim upon saving {{{
-- augroup vimrc
--     autocmd!
--     autocmd! BufWritePost $MYVIMRC,nvim-init.vim nested source $MYVIMRC | set foldmethod=marker | echo "Reloaded neovim"
-- augroup END
-- " }}}
-- " Markdown options {{{
-- function! MathAndLiquid()
--     syn region math start=/\$\$/ end=/\$\$/
--     syn match math_block '\$[^$].\{-}\$'
--     syn match liquid '{%.*%}'
--     syn region highlight_block start='{% highlight .*%}' end='{%.*%}'
--     syn region highlight_block start='```' end='```'
--     hi link math Statement
--     hi link liquid Statement
--     hi link highlight_block Function
--     hi link math_block Function
-- endfunction
-- augroup MDoptions
--     autocmd!
--     autocmd BufNewFile,BufRead *.md set nolist | inoremap <silent> <C-L>  <c-g>u<Esc>[s1z=`]a<c-g>u
--     autocmd BufRead,BufNewFile,BufEnter *.md,*.markdown call MathAndLiquid()
-- augroup END
-- " }}}
-- " Tex options {{{
-- augroup TEXoptions
--     autocmd!
--     autocmd BufNewFile,BufRead *.tex set nolist | setlocal spell | inoremap <silent> <C-L>  <c-g>u<Esc>[s1z=`]a<c-g>u
-- augroup END
-- " }}}
-- " Enable indent-blankline for some filetypes only {{{
-- augroup IndentFT
--     autocmd!
--     autocmd BufNewFile,BufRead *.{vim,ipynb,tex,py,lua,cpp,css,sh,ini,conf,html,json,toml,zsh,yaml,xml} silent! IndentBlanklineEnable
--     autocmd BufNewFile,BufRead *.{vim,ipynb,tex,py,lua,cpp,css,sh,ini,conf,html,json,toml,zsh,yaml,xml} nnoremap <silent> zA zA:IndentBlanklineRefresh<CR> | nnoremap <silent> za za:IndentBlanklineRefresh<CR> | nnoremap <silent> zm zm:IndentBlanklineRefresh<CR> | nnoremap <silent> zM zM:IndentBlanklineRefresh<CR> | nnoremap <silent> zc zc:IndentBlanklineRefresh<CR> | nnoremap <silent> zC zC:IndentBlanklineRefresh<CR> | nnoremap <silent> zr zr:IndentBlanklineRefresh<CR> | nnoremap <silent> zR zR:IndentBlanklineRefresh<CR>
-- augroup END
-- " }}}
-- " Terminal no number {{{
-- augroup floaterm
--     autocmd!
--     autocmd Filetype floaterm set nonumber | set norelativenumber
-- augroup END
-- " }}}
-- " Highlight current matched search {{{
-- augroup procsearch
--   autocmd!
--   au CmdLineLeave * let b:cmdtype = expand('<afile>') | if (b:cmdtype == '/' || b:cmdtype == '?') | call timer_start(200, 'ProcessSearch') | endif
-- augroup END
-- function! ProcessSearch(timerid)
--     let l:patt = '\%#' . @/
--     if &ignorecase | let l:patt = '\c' . l:patt | endif
--     exe 'match IncSearch /' . l:patt . '/'
-- endfunc
-- " }}}
-- " Fold with treesitter {{{
-- augroup FoldTS
--     autocmd!
--     au BufNewFile,BufRead *.{vim,tex,py,lua,cpp,sh,toml} set foldmethod=expr | set foldexpr=nvim_treesitter#foldexpr()
-- augroup END
-- " }}}
-- " Auto close nvim-tree {{{
-- augroup nvimtreeclose
--     autocmd!
--     autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
-- augroup END
-- " Telescope no prompt {{{
-- augroup TelescopeStuff
-- autocmd FileType TelescopePrompt lua require'cmp'.setup.buffer {
-- \   completion = { autocomplete = false }
-- \ }
-- augroup END
-- " }}}
-- " }}}
-- " }}}
-- " FUNCTIONS {{{
-- " Toggle number {{{
-- function! SetNumber()
--     if &number
--         if &relativenumber
--             setlocal nonumber
--             setlocal norelativenumber
--         else
--             setlocal relativenumber
--         endif
--     else
--         setlocal number
--     endif
-- endfunction
-- " }}}
-- " Toggle paste mode {{{
-- set pastetoggle=<F2>
-- function! ShowPaste()
--     if &paste
--         set showmode
--     else
--         set noshowmode
--     endif
-- endfunction
-- augroup showpaste
--     autocmd InsertLeave,InsertEnter * call ShowPaste()
-- augroup END
-- " }}}
-- " Idk what this is {{{
-- function! s:s(delta) abort
-- if pumvisible()
--   let l:i = complete_info(['selected']).selected
--   call timer_start(0, { -> nvim_select_popupmenu_item(l:i + a:delta, v:true, v:false, {}) })
-- endif
-- return "\<Ignore>"
-- endfunction
-- " }}}
-- " Delete whitespace {{{
-- function TrimWhiteSpace()
--   %s/\s*$//
--   ''
-- endfunction
-- " }}}
-- " Toggle foldcolumn {{{
-- function! FoldColumnToggle()
--     if &foldcolumn
--         setlocal foldcolumn=0
--     else
--         setlocal foldcolumn=4
--     endif
-- endfunction
-- " }}}
-- " Toggle cmp {{{
-- function ToggleCmp()
--     if g:cmp_toggle==v:true
--         let g:cmp_toggle=v:false
--     else
--         let g:cmp_toggle=v:true
--     endif
-- endfunction
-- " }}}
-- " }}}
-- lua require'utils.settings'

-- Integrated terminal
vim.cmd [[
    au BufEnter * if &buftype == 'terminal' | :startinsert | endif
    function! OpenTerminal()
        split term://zsh
    endfunction
]]

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

vim.cmd([[
    syntax on "some nice and fancy syntax highlight
    filetype plugin on "auxiliates in filetype dependant behaviour
]])

-- setting gruvbox as colorscheme in manpages also disable italics :)
vim.cmd([[
    autocmd FileType man colorscheme gruvbox
]])

local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
    print("impatient-nvim not installed yet, it will work from the next neovim start")
-- else 
--     require('impatient')
end
require('plugins')
require('mappings').setup_basic_mappings()
