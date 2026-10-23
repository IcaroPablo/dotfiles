local map = require("core.map")

return {
    "smoka7/hop.nvim",
    config = function()
        local hop = require("hop")

        hop.setup({
            keys = "etovxqpdygfblzhckisuran",
            hl_mode = "replace",
        })

        local directions = require("hop.hint").HintDirection

        map.set("", "f", function()
            hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
        end, { remap = true })
        map.set("", "F", function()
            hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
        end, { remap = true })
        map.set("", "t", function()
            hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
        end, { remap = true })
        map.set("", "T", function()
            hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
        end, { remap = true })
        map.set("", "<leader>l", function()
            hop.hint_vertical()
        end, { remap = true })
    end,
}
