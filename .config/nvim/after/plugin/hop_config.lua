local hop = require('hop')

hop.setup {
    keys = 'etovxqpdygfblzhckisuran',
    hl_mode = 'replace'
}

local directions = require('hop.hint').HintDirection

vim.keymap.set('', 'f', function() hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true }) end, {remap=true})
vim.keymap.set('', 'F', function() hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true }) end, {remap=true})
vim.keymap.set('', 't', function() hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }) end, {remap=true})
vim.keymap.set('', 'T', function() hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 }) end, {remap=true})
vim.keymap.set('', '<leader>l', function() hop.hint_vertical() end, {remap=true})
-- vim.keymap.set('', '<leader>c', ':HopCamelCaseCurrentLine<CR>', {remap=true})
vim.keymap.set('', '<leader>w', function() hop.hint_words({current_line_only = true}) end, {remap=true})
-- vim.keymap.set('', '<leader>W', function() hop.hint_words({ direction = directions.BEFORE_CURSOR, current_line_only = true}) end, {remap=true})
-- hopnodes
