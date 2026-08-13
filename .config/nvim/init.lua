--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

vim.opt.laststatus = 2 -- last window will always have a status line (?)
-- vim.opt.statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}
vim.opt.showmode = false -- the status bar already shows the current mode
vim.opt.showcmd = false -- don't really remember :)

vim.opt.autoindent = true -- self-describing
vim.opt.smartindent = true -- inserts an automatic indent after common C-like expressions or keywords

vim.opt.errorbells = false -- self-describing
vim.opt.wrap = true -- wrap lines

vim.opt.smartcase = true -- searches are case sensitive only if uppercase is used
vim.opt.ignorecase = true -- has to be set for smartcase to work properly

-- vim.opt.hlsearch = false            -- remove highlights from search
vim.opt.incsearch = true -- search results are showed in real time

vim.opt.number = true -- numbered lines
vim.opt.relativenumber = true -- numbered lines are now relative to the current line
vim.opt.cursorline = true -- display the current line

vim.opt.expandtab = true -- uses tabs instead of spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.splitbelow = true -- horizontal split goes below the current window
vim.opt.splitright = true -- vertical split goes right of the current window

vim.opt.termguicolors = true -- uses true color
vim.opt.swapfile = false -- self-describing
-- vim.opt.updatetime = 50
-- vim.opt.shadafile = "NONE"
vim.opt.scrolloff = 10 -- offvim.opt.for scrolling
-- vim.opt.path += **                  -- useful for :find

vim.opt.history = 1000
vim.opt.undodir = vim.fn.expand("~/.vim/backup")
vim.opt.undofile = true
vim.opt.undoreload = 10000

vim.opt.wildmenu = true -- useful for autocompletion
vim.opt.clipboard = "unnamedplus" -- uses the + register (aka the system clipboard) as vim clipboard
vim.opt.mouse = "a" -- pretend you didn't see this shit here

vim.g.mapleader = " "

if not vim.loader.enabled then
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
vim.cmd([[
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

-- vim.api.nvim_create_user_command("SetDotfilesGitVars", function()
--     vim.env.GIT_WORK_TREE = vim.fn.expand("~")
--     vim.env.GIT_DIR = vim.fn.expand("~/.config/dotfiles")
-- end, {})

-- vim.api.nvim_create_user_command("DisableLSPColors", function()
--     for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
--         vim.api.nvim_set_hl(0, group, {})
--     end
-- end, {})

vim.api.nvim_create_user_command("Dig", function()
    local root_dir = get_root()

    if root_dir ~= nil then
        vim.cmd("cd " .. root_dir)
    else
        print("root not found")
    end
end, {})

-- ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
-- ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
-- ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
-- ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
-- ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
-- ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- lua =require("lazy").stats().count

require("lazy").setup({
    "smoka7/hop.nvim",
    -- "mbbill/undotree",
    "lukas-reineke/indent-blankline.nvim",
    {
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
    },
    -- {
    --     "folke/zen-mode.nvim",
    --     dependencies = {
    --         { "folke/twilight.nvim", config = true },
    --     },
    --     cmd = "ZenMode",
    -- },
    -- {
    --     "sindrets/diffview.nvim",
    --     dependencies = { "kyazdani42/nvim-web-devicons" },
    -- },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
    },
    {
        "Shatur/neovim-session-manager",
        dependencies = {
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "gruvbox-community/gruvbox",
        lazy = false,
        priority = 1000,
        init = function()
            vim.g.gruvbox_bold = "0"
            vim.g.gruvbox_contrast_dark = "hard"
        end,
        config = function()
            vim.cmd([[ colorscheme gruvbox ]])
        end,
    },
    -- alternativa (reescrita Lua, mantida): ellisonleao/gruvbox.nvim
    -- {
    --     'ellisonleao/gruvbox.nvim',
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require('gruvbox').setup({
    --             terminal_colors = true,
    --             undercurl = false,
    --             underline = false,
    --             bold = false,
    --             italic = {
    --                 strings = false,
    --                 emphasis = false,
    --                 comments = false,
    --                 operators = false,
    --                 folds = false,
    --             },
    --             strikethrough = true,
    --             invert_selection = true,
    --             invert_signs = true,
    --             invert_tabline = false,
    --             invert_intend_guides = false,
    --             inverse = false,
    --             contrast = 'hard', -- "hard", "soft" ou ""
    --             dim_inactive = false,
    --             transparent_mode = false,
    --         })
    --         vim.cmd('colorscheme gruvbox')
    --     end,
    -- },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            -- nice to have: telescope-file-browser, telescope-frecency, telescope-zoxide, telescope-dict
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "command -v gmake >/dev/null 2>&1 && gmake || make",
            },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
        },
    },
}, {
    change_detection = { notify = false },
})

-- ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║╚════██║
-- ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝███████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

function get_root()
    return vim.fs.root(0, { ".git", ".gitignore", "mvnw", "gradlew", "pom.xml" })
end

function open_terminal_in(project_folder)
    local nvim_socket = "export NVIM='" .. vim.v.servername .. "'"
    local initial_folder_command = "export INITIAL_FOLDER=" .. project_folder
    local terminal_command = nvim_socket .. " ; " .. initial_folder_command .. " ; " .. os.getenv("NVIM_TERM_CMD")
    local full_command = terminal_command .. " 2>/dev/null &"

    os.execute(full_command)
end

function PipeToCommand()
    local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local selected_text = table.concat(lines, "\n")

    local command = vim.fn.input("command: ")
    local full_command = 'echo "' .. selected_text .. '" | ' .. command .. " 2>/dev/null 1>/dev/null &"
    -- print(full_command)

    local handle = os.execute(full_command)
    -- handle:close()

    -- print(output)
end

function log_messages()
    vim.cmd("redir! > ~/nvim_msgs.txt")
end

-- easily manage buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>:redraw<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>:redraw<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":call EasyClose()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>Q", ":quit!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", ":enew | startinsert<CR>", { noremap = true, silent = true }) -- New file
vim.keymap.set("n", "<leader>C", ":e $HOME/.config/nvim/init.lua<CR>", { noremap = true, silent = true }) -- Configs
-- Format the whole nvim config with StyLua
vim.keymap.set("n", "<leader>F", function()
    if vim.fn.executable("stylua") == 0 then
        vim.notify("stylua não encontrado no PATH", vim.log.levels.WARN)
        return
    end
    local out = vim.fn.system({ "stylua", vim.fn.stdpath("config") })
    if vim.v.shell_error ~= 0 then
        vim.notify(out, vim.log.levels.ERROR)
    else
        vim.cmd("checktime") -- recarrega buffers reformatados no disco
        vim.notify("StyLua: config formatada", vim.log.levels.INFO)
    end
end, { noremap = true, silent = true, desc = "Format nvim config with StyLua" })
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
vim.keymap.set("", "<c-l>", "<c-w>l", { noremap = true, silent = true })

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
vim.keymap.set("n", "tt", function()
    open_terminal_in(vim.fn.expand("%:p:h"))
end, { noremap = true, silent = true })
vim.keymap.set("n", "TT", function()
    local project_folder = get_root() or vim.fn.expand("%:p:h")

    open_terminal_in(project_folder)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-f>", function()
    -- local current_dir = vim.fn.expand('%:p:h')
    local current_file = vim.fn.expand("%:t")

    local nvim_socket = "export NVIM='" .. vim.v.servername .. "' && "
    local terminal_command = nvim_socket .. os.getenv("NVIM_TERM_CMD")
    local command = "lf " .. (current_file:find("^.") ~= nil and "--command 'set hidden' " or "") .. vim.fn.expand("%:p")
    local full_command = terminal_command .. " " .. command .. " 2>/dev/null 1>/dev/null &"

    os.execute(full_command)
end, { noremap = true, silent = true })

-- navigate quickfixes
vim.keymap.set("n", "<c-p>", ":cprev<CR>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-n>", ":cnext<CR>zz", { noremap = true, silent = true })

-- center search results
-- vim.keymap.set("n", "n", "nzz", {noremap = true, silent = true})
-- vim.keymap.set("n", "N", "Nzz", {noremap = true, silent = true})
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-o>", "<C-o>zz")
vim.keymap.set("n", "<C-i>", "<C-i>zz")
-- vim.keymap.set("n", "#", "#zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g*", "g*zz", { silent = true, noremap = true })
-- vim.keymap.set("n", "g#", "g#zz", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>w", "*N", { silent = true, noremap = true })
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- deactivate space because of annoying behaviour since its my leader key :)
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true })

-- word substitution
-- vim.keymap.set("n", "<C-j>", "ciw<C-r>0<ESC>", {silent = true})
vim.keymap.set("n", "<C-s>", '"1yiwciw<C-r>0<ESC>/<C-r>1<CR>', { silent = true })
vim.keymap.set("n", "<Leader>jq", ":%!jq '.'<CR>", { silent = true })

-- other niceties
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
vim.keymap.set("n", "<Leader><Leader>", ":write<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<c-[>", "<esc>:nohlsearch<CR>", { silent = true })
-- vim.keymap.set('v', '<leader>p', function() PipeToCommand() end, { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>p", ":lua PipeToCommand()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>r", "vip:lua PipeToCommand()<CR>q<CR>", { noremap = true, silent = true })
