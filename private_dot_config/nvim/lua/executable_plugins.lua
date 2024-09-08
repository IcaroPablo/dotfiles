
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
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

-- Autosource plugins file after saving
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerSync
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
        prompt_border = 'double'                    -- border style of prompt popups.
    }
})

return require('packer').startup(function(use)
    -- https://github.com/sindrets/diffview.nvim
    -- magit
    -- tabnine
        -- https://github.com/tzachar/cmp-tabnine
        -- https://www.tabnine.com/install/neovim
    use({
        "lewis6991/gitsigns.nvim",
        event = "BufRead",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require('gitsigns').setup()
        end,
    })
    --use({
        --"sindrets/diffview.nvim",
        --cmd = {
            --"DiffviewOpen",
            --"DiffviewFileHistory",
        --},
        --config = function()
            --require("configs.diffview")
        --end,
    --})
    -- use 'nvim-telescope/telescope-file-browser.nvim' -- file browser for telescope
    -- use 'jose-elias-alvarez/null-ls.nvim'
    -- use 'windwp/nvim-autopairs'
    -- use 'norcalli/nvim-colorizer.lua'
    -- use 'lewis6991/gitsigns.nvim'
    -- use 'muniftanjim/nui.nvim'
    --use({
        --"NTBBloodbath/galaxyline.nvim",
        --event = "VimEnter",
        --branch = "main",
        --wants = "nvim-web-devicons",
        --config = function()
            --require("configs.statusline")
        --end,
    --})
    ---- COLORIZER: add a colored background for color codes
    --use({
        --"norcalli/nvim-colorizer.lua",
        --ft = {
            --"html",
            --"css",
            --"sass",
            --"vim",
            --"lua",
            --"javascript",
            --"typescript",
            --"dosini",
            --"ini",
            --"conf",
            --"json",
            --"cfg",
        --},
        --cmd = { "ColorizerToggle" },
        --config = function()
            --require("colorizer").setup()
            --vim.cmd("ColorizerAttachToBuffer")
        --end,
    --})
    --use("nvim-lua/lsp-status.nvim")
    --use({
        --"folke/zen-mode.nvim",
        --wants = "twilight.nvim",
        --cmd = "ZenMode",
        --config = function()
            --require("configs.zen")
        --end,
    --})
    --use({
        --"folke/twilight.nvim",
        --cmd = "Twilight",
        --config = function()
            --require("twilight").setup()
        --end,
    --})
    -- use({
    --     'nvimdev/indentmini.nvim',
    --     config = function()
    --         require("indentmini").setup() -- use default config
    --     end
    -- })
    use({ -- INDENT-BLANKLINE: display indent lines (even on blank lines)
        "lukas-reineke/indent-blankline.nvim",
        -- cmd = {
        --     "IndentBlanklineEnable",
        --     "IndentBlanklineToggle",
        -- },
    })
    use({
        'oysandvik94/curl.nvim',
        requires = {
            'mfussenegger/nvim-dap'
        }
    })
    --use({ -- NEOSCROLL: smooth scrolling
        --"karb94/neoscroll.nvim",
        --event = "WinScrolled",
        --config = function()
            --require("configs.neoscroll")
        --end,
    --})
    --use({
        --"b3nj5m1n/kommentary",
        --event = "CursorMoved",
        --config = function()
            --require("configs.comment")
        --end,
    --})
    --use({
        --"max397574/better-escape.nvim",
        --event = "InsertEnter",
        --config = function()
            --require("configs.escape")
        --end,
    --})
    --use({
        --"LunarWatcher/auto-pairs",
        --event = "BufEnter",
        --config = function()
            --require("configs.autopairs")
        --end,
    --})
    --use({
        --"junegunn/vim-easy-align",
        --keys = "<Plug>(EasyAlign)",
    --})
    --use({
        --"mbbill/undotree",
        --cmd = "UndotreeToggle",
        --config = function()
            --require("configs.undotree")
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
    --use({
        --"tversteeg/registers.nvim",
        --event = "BufEnter",
        --config = function()
            --vim.g.registers_show_empty_registers = 0
            --vim.g.registers_hide_only_whitespace = 1
            --vim.g.registers_window_border = "rounded"
            --vim.g.registers_window_max_width = 50
            --vim.g.registers_window_min_height = 3
        --end,
    --})
    --use({
        --"godlygeek/tabular",
    --})
    --use({
        --"chentau/marks.nvim",
        --ft = "markdown",
        --config = function()
            --require("configs.marks")
        --end,
    --})
    --use({
        --"nmac427/guess-indent.nvim",
        --event = "BufEnter",
        --config = function()
            --require("guess-indent").setup()
        --end,
    --})
    use 'shortcuts/no-neck-pain.nvim'
    use 'vinnymeller/swagger-preview.nvim'
    use 'wbthomason/packer.nvim'
    use 'l3mon4d3/luasnip'
    use 'saadparwaiz1/cmp_luasnip'
    use 'tpope/vim-commentary'
    -- use 'yggdroot/indentline'
    use 'nvim-treesitter/nvim-treesitter'
    ---- TS-RAINBOW: treesitter rainbow parentheses
    --use({
        --"p00f/nvim-ts-rainbow",
        --event = "BufRead",
    --})
    ----
    ---- TS-PLAYGROUND: see treesitter syntax tree
    --use({
        --"nvim-treesitter/playground",
        --cmd = { "TSPlaygroundToggle" },
    --})
    --use({
        --"nvim-treesitter/nvim-treesitter",
        --run = ":TSUpdate",
        --config = function()
            --require("configs.treesitter")
        --end,
    --})
    use 'neovim/nvim-lspconfig'
    --use({
        --"neovim/nvim-lspconfig",
        --event = "BufRead",
        --after = "cmp-nvim-lsp",
        --config = function()
            --require("configs.lspconfig")
        --end,
    --})
    --use({
        --"ray-x/lsp_signature.nvim",
        --event = "InsertEnter",
    --})
    --use({
        --"simrat39/symbols-outline.nvim",
        --cmd = {
            --"SymbolsOutline",
            --"SymbolsOutlineOpen",
            --"SymbolsOutlineClose",
        --},
        --setup = function()
            --require("configs.outline")
        --end,
    --})
    ----
    ---- GLOW-HOVER: uses glow for lsp hover diagnostics
    ----[[ use({
        --"JASONews/glow-hover",
        --config = function()
            --require("glow-hover").setup({
                --max_width = 50,
                --padding = 10,
                --border = "rounded",
                --glow_path = "glow",
            --})
        --end,
    --}) ]]
    ----
    ---- TEXLABCONFIG: texlab stuff
    --use({
        --"f3fora/nvim-texlabconfig",
        --config = function()
            --require("texlabconfig").setup()
        --end,
        --ft = { "tex", "bib" },
        --cmd = { "TexlabInverseSearch" },
    --})
    ----
    ---- TROUBLE: pretty list of diagnostics
    --use({
        --"folke/trouble.nvim",
        --requires = "kyazdani42/nvim-web-devicons",
        --config = function()
            --require("configs.trouble")
        --end,
    --})
    ----
    ---- NULL-LS: LSP goodies
    --use({
        --"jose-elias-alvarez/null-ls.nvim",
        --event = "BufRead",
        --config = function()
            --require("configs.null")
        --end,
    --})
    ----
    ---- LSP-LINES: replace virtual text with diagnostic lines
    ----[[ use({
        --"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        --event = "BufRead",
        --config = function()
            --require("lsp_lines").register_lsp_virtual_lines()
        --end,
    --}) ]]
    ---- -_-_-_-_- DAP _-_-_-_-_-_
    ---- DAP-PYTHON: Debugging python
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
    ----
    ---- DAP: API for debuggers
    --use({
        --"mfussenegger/nvim-dap",
        --module = "dap",
        --config = function()
            --require("configs.dap")
        --end,
    --})
    ----
    ---- DAP-VIRTUAL-TEXT: Display variable expressions as virtual text
    --use({
        --"theHamsta/nvim-dap-virtual-text",
        --after = "nvim-dap",
        --config = function()
            --require("nvim-dap-virtual-text").setup()
        --end,
    --})
    ----
    ---- DAP-UI: Sane ui for debuggers
    --use({
        --"rcarriga/nvim-dap-ui",
        --module = "dapui",
        --requires = { "mfussenegger/nvim-dap" },
    --})
    ----
    ---- HILINKTRACE: See current highlight group
    ----[[ use({
        --"gerw/vim-HiLinkTrace",
    --}) ]]
    use 'anuvyklack/pretty-fold.nvim'
    --use({
        --"lewis6991/foldsigns.nvim",
        --event = "BufRead",
        --config = function()
            --require("foldsigns").setup({
                --exclude = { "LspDiagnosticsSignWarning" },
            --})
        --end,
    --})
    ----[[ use({
        --"lewis6991/cleanfold.nvim",
        --commit = "ed54df0",
        --event = "BufRead",
        --config = function()
            --require("cleanfold").setup()
        --end,
    --}) ]]
    -- require('lualine').setup {
    --   options = { theme = 'onedark' },
    -- }
    use {
        'mfussenegger/nvim-jdtls',
        requires = {
            'mfussenegger/nvim-dap'
        }
    }
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
        'lewis6991/impatient.nvim',
        --rocks = "mpack",
        requires = {
            "nvim-lua/plenary.nvim"
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
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        -- 'itchyny/lightline.vim',
        -- config = function ()
        --     -- vim.cmd [[
        --     --     let g:lightline = {
        --     --         \ 'colorscheme': 'apprentice',
        --     --         \ 'component_function': {
        --     --         \   'filename': 'LightlineFilename',
        --     --         \ },
        --     --         \ }

        --     --     function! LightlineFilename()
        --     --       return &filetype ==# 'vimfiler' ? vimfiler#get_status_string() :
        --     --             \ &filetype ==# 'unite' ? unite#get_status_string() :
        --     --             \ &filetype ==# 'vimshell' ? vimshell#get_status_string() :
        --     --             \ expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
        --     --     endfunction
        --     -- ]]

        --     vim.g.lightline = {
        --         colorscheme = 'apprentice', -- seoul256, jellybeans, darcula, deus, apprentice
        --         component_function = {
        --             filename = vim.fn.expand('%:t') == '' and '[No Name]' or vim.fn.expand('%:t')
        --         }
        --     }
        -- end
    }
    use { -- improves telescope's performance
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    }
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.x',
        requires = {
            -- consider installing ripgrep
            -- consider installing sharkdp/fd
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim'
            -- {
            --     "nvim-telescope/telescope-file-browser.nvim",
            --     module = "telescope",
            -- },
            -- {
            --     "nvim-telescope/telescope-fzf-native.nvim",
            --     cmd = "Telescope",
            --     run = "make",
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
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip'
        },
    }
    use({
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
        end
    })
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
    --use({
        --"hrsh7th/nvim-cmp",
        --after = "ultisnips",
        --config = function()
            --require("configs.cmp")
        --end,
    --})
    --use({
        --"quangnguyen30192/cmp-nvim-ultisnips",
        --after = "nvim-cmp",
    --})
    --use({
        --"hrsh7th/cmp-nvim-lsp",
        --after = "nvim-cmp",
    --})
    --use({
        --"hrsh7th/cmp-path",
        --after = "cmp-nvim-lsp",
    --})
    --use({
        --"hrsh7th/cmp-buffer",
        --after = "cmp-path",
    --})
    --use({
        --"gelguy/wilder.nvim",
        --run = ":UpdateRemotePlugins",
        --event = "CmdlineEnter",
        --config = function()
            --vim.cmd([[ source $HOME/.config/nvim/lua/configs/wilder.vim ]])
        --end,
    --})
    use {
        'nvim-neo-tree/neo-tree.nvim',
        branch = "v2.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim"
        },
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
