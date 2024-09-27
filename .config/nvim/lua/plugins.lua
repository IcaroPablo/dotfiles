
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
        -- prompt_border = 'double'                    -- border style of prompt popups.
    }
})

return require('packer').startup(function(use)
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
