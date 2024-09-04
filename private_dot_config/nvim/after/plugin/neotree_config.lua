-- verificar instalação

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
require("neo-tree").setup({
    close_if_last_window = true,
    enable_diagnostics = true,
    enable_git_status = true,
    popup_border_style = "rounded",
    sort_case_insensitive = false,
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false
        }
    },
    window = { -- see https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for possible options. These can also be functions that return these options.
        position = "float", -- left, right, top, bottom, float, current
        -- width = 30, -- applies to left and right positions
        popup = { -- settings that apply to float position only
            size = {
                height = "80%",
                width = "50%"
            }
        }
    }
})

require('mappings').setup_neotree()
