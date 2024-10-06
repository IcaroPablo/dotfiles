
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
    local root_dir = get_root()

    if(root_dir ~= nil) then
        vim.cmd('cd ' .. root_dir)
    else
        print('root not found')
    end
end, {})

-- ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
-- ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
-- ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
-- ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
-- ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
-- ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝

-- bootstrap packer
local ensure_packer = function()
    local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.cmd [[packadd packer.nvim]]
        vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        return true
    end
    return false
end

-- Autosource plugins file after saving
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost init.lua source <afile> | PackerSync
    augroup end
]])

local packer_bootstrap = ensure_packer()

-- require('packer').reset()
require('packer').init({
    ensure_dependencies = true,                     -- Should packer install plugin dependencies?
    auto_clean = true,                              -- During sync(), remove unused plugins
    autoremove = true,                              -- Remove disabled or unused plugins without prompting the user
    compile_on_sync = true,                         -- during sync(), run packer.compile()
    transitive_disable = true,                      -- automatically disable dependencies of disabled plugins
    auto_reload_compiled = true,                    -- automatically reload the compiled file after creating it.
    preview_updates = false,                        -- if true, always preview updates before choosing which plugins to update, same as `packerupdate --preview`.
    display = {
        non_interactive = false,                    -- if true, disable display windows for all operations
        compact = true,                             -- if true, fold updates results by default
        open_fn  = require('packer.util').float,    -- an optional function to open a window for packer's display
        show_all_info = true,                       -- should packer show all update details automatically?
        -- prompt_border = 'double'                    -- border style of prompt popups.
    }
})

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use {
        'smoka7/hop.nvim',
        tag = '*', -- optional but strongly recommended
    }
    use({
        "lewis6991/gitsigns.nvim",
        -- event = "BufRead",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require('gitsigns').setup({
                on_attach = function(bufnr)
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                      if vim.wo.diff then
                        vim.cmd.normal({']c', bang = true})
                      else
                        require('gitsigns').nav_hunk('next')
                      end
                    end)

                    map('n', '[c', function()
                      if vim.wo.diff then
                        vim.cmd.normal({'[c', bang = true})
                      else
                        require('gitsigns').nav_hunk('prev')
                      end
                    end)

                    -- Actions
                    map('n', '<leader>hr', require('gitsigns').reset_hunk)
                    map('n', '<leader>hR', require('gitsigns').reset_buffer)
                    map('n', '<leader>hp', require('gitsigns').preview_hunk)
                    map('n', '<leader>td', require('gitsigns').toggle_deleted)

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            })
        end
    })
    use({
        "folke/zen-mode.nvim",
        requires = {
            "folke/twilight.nvim",
            cmd = "Twilight",
            config = function()
                require("twilight").setup()
            end,
        },
        cmd = "ZenMode",
    })
    use {
        'sindrets/diffview.nvim',
        requires = {
            "kyazdani42/nvim-web-devicons",
        }
    }
    use 'mbbill/undotree'
    use 'lukas-reineke/indent-blankline.nvim'
    -- use({
    --     'oysandvik94/curl.nvim',
    --     requires = {
    --         'mfussenegger/nvim-dap'
    --     }
    -- })
    -- use 'windwp/nvim-autopairs'
    --use({
        --"LunarWatcher/auto-pairs",
        --event = "BufEnter",
        --config = function()
            --require("configs.autopairs")
        --end,
    --})
    --use({
        --"ur4ltz/surround.nvim",
        --event = "BufEnter",
        --config = function()
            --require("surround").setup({
                --mappings_style = "surround",
                --space_on_alias = false,
                --space_on_closing_char = false,
            --})
        --end,
    --})
    use 'vinnymeller/swagger-preview.nvim'
    use 'l3mon4d3/luasnip'
    use 'saadparwaiz1/cmp_luasnip'
    --use({
        --"quangnguyen30192/cmp-nvim-ultisnips",
        --after = "nvim-cmp",
    --})
    --use({
        --"sirver/ultisnips",
        --event = "InsertEnter",
        --setup = function()
            --vim.g.UltiSnipsExpandTrigger = "<nop>"
            --vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
            --vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
            --vim.g.UltiSnipsRemoveSelectModeMappings = 0
        --end,
        --config = function()
            --vim.cmd('let g:UltiSnipsSnippetDirectories=[$HOME."/.config/nvim/ultisnips"]')
        --end,
    --})
    -- use 'nvim-treesitter/nvim-treesitter-context'
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    })
    use({
        "neovim/nvim-lspconfig",
        --event = "BufRead",
        --after = "cmp-nvim-lsp",
    })
    use {
        'goolord/alpha-nvim',
        requires = {
            'nvim-telescope/telescope.nvim',
            'Shatur/neovim-session-manager'
        }
    }
    use {
        'Shatur/neovim-session-manager',
        requires = {
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-lua/plenary.nvim'
        }
    }
    use {
        'gruvbox-community/gruvbox',
        config = function ()
            vim.g.gruvbox_bold = '0'
            -- vim.g.gruvbox_italic = false
            -- vim.g.gruvbox_italicize_comments = '0'
            -- vim.g.gruvbox_italicize_strings = '0'
            vim.g.gruvbox_contrast_dark = 'hard'
            vim.cmd([[ colorscheme gruvbox ]])
        end
    }
    -- use {
    --     "ellisonleao/gruvbox.nvim",
    --     config = function()
    --         require("gruvbox").setup({
    --             terminal_colors = true, -- add neovim terminal colors
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
    --             inverse = false, -- invert background for search, diffs, statuslines and errors
    --             contrast = "hard", -- can be "hard", "soft" or empty string
    --             -- palette_overrides = {},
    --             -- overrides = {},
    --             dim_inactive = false,
    --             transparent_mode = false,
    --         })

    --         vim.cmd("colorscheme gruvbox")
    --     end
    -- }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use {
        'nvim-telescope/telescope.nvim',
        -- tag = '0.1.8',
        branch = '0.1.x',
        requires = {
            -- consider installing ripgrep
            -- consider installing sharkdp/fd
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
            -- {
            --     "nvim-telescope/telescope-file-browser.nvim",
            --     module = "telescope",
            -- },
            -- {
            --     "nvim-telescope/telescope-fzf-native.nvim",
            --     cmd = "Telescope",
            -- },
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
                -- run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
                -- run = "make",
                run = "gmake",
            }
            -- {
            --     "nvim-telescope/telescope-frecency.nvim",
            --     requires = { 'nvim-tree/nvim-web-devicons', opt = true }
            -- },
            -- {
            --     "jvgrootveld/telescope-zoxide",
            --     cmd = "Telescope",
            -- },
            -- {
            --     "rudism/telescope-dict.nvim",
            --     filetype = { "markdown", "tex" },
            -- },
        },
    }
    use {
        "williamboman/mason.nvim",
        requires = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig"
        },
        config = function()
            require('mason').setup()
            require("mason-lspconfig").setup()
        end
    }
    use {
        'hrsh7th/nvim-cmp',
        --after = "ultisnips",
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip'
        },
    }
    --use({
        --"mfussenegger/nvim-dap-python",
        --after = "nvim-dap",
        --config = function()
            --require("dap-python").setup(
                --"/home/lckdscl/.local/share/applications/debugpy/bin/python",
                --{ justMyCode = false }
            --)
        --end,
    --})
    use {
        'mfussenegger/nvim-jdtls',
        --module = "dap",
        requires = {
            'mfussenegger/nvim-dap'
        }
    }
    --use({
        --"theHamsta/nvim-dap-virtual-text",
        --after = "nvim-dap",
        --config = function()
            --require("nvim-dap-virtual-text").setup()
        --end,
    --})
    --use({
        --"rcarriga/nvim-dap-ui",
        --module = "dapui",
        --requires = { "mfussenegger/nvim-dap" },
    --})

    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║╚════██║
-- ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝███████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

function get_root()
   return vim.fs.root(0, {".git", ".gitignore", "mvnw", "gradlew", "pom.xml"})
end

function open_terminal_in(project_folder)
    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port
    local initial_folder_command = "export INITIAL_FOLDER=" .. project_folder
    local terminal_command = nvim_socket  .. " ; " .. initial_folder_command .. " ; " .. os.getenv('NVIM_TERM_CMD')
    local full_command = terminal_command .. ' 2>/dev/null &'

    os.execute(full_command)
end

function log_messages()
    vim.cmd('redir! > ~/nvim_msgs.txt')
end

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
vim.keymap.set("n", "TT", function() open_terminal_in(vim.fn.expand('%:p:h')) end, { noremap = true, silent = true })
vim.keymap.set("n", "tt", 
    function()
        local project_folder = get_root() or vim.fn.expand('%:p:h')

        open_terminal_in(project_folder)
    end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-f>",
    function()
        -- local current_dir = vim.fn.expand('%:p:h')
        local current_file = vim.fn.expand("%:t")

        local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port .. " && "
        local terminal_command = nvim_socket .. os.getenv('NVIM_TERM_CMD')
        local command = 'lf ' .. (current_file:find('^.') ~= nil and '--command \'set hidden\' ' or '') .. vim.fn.expand('%:p')
        local full_command = terminal_command .. ' ' .. command .. ' 2>/dev/null 1>/dev/null &'

        os.execute(full_command)
    end, {noremap = true, silent = true})

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
