local custom_gruvbox = require('lualine.themes.gruvbox_dark')

custom_gruvbox.normal.a.gui = ''
custom_gruvbox.insert.a.gui = ''
custom_gruvbox.visual.a.gui = ''
custom_gruvbox.replace.a.gui = ''
custom_gruvbox.command.a.gui = ''
custom_gruvbox.inactive.a.gui = ''

local setup = {
    options = { theme  = custom_gruvbox },
    sections = {
        lualine_a = {
            {
                'diagnostics',

                -- Table of diagnostic sources, available sources are:
                --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                -- or a function that returns a table as such:
                --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                sources = {'nvim_lsp'},

                -- Displays diagnostics for the defined severity types
                sections = { 'error', 'warn', 'info', 'hint' },

                -- diagnostics_color = {
                --     -- Same values as the general color option can be used here.
                --     error = 'DiagnosticError', -- Changes diagnostics' error color.
                --     warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
                --     info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
                --     hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
                -- },
                symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
                colored = false,           -- Displays diagnostics status in color if set to true.
                update_in_insert = false, -- Update diagnostics in insert mode.
                always_visible = false,   -- Show diagnostics even if there are none.
            }
        }
    }
}

require('lualine').setup(setup)
