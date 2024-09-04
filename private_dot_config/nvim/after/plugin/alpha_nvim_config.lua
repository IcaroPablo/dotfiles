local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
    return
end

local dashboard = require('alpha.themes.dashboard')

-------------------------------------------------------------

-- local header = "lol"
local header = {
    type = "text",
    val = {
"                                                     ",
"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
"                                                     ",
    },
    opts = {
        position = "center",
        hl = "Type"
        -- wrap = "overflow";
    }
}

local buttons = {
    type = "group",
    val = {
        dashboard.button("n", "  New file", ":ene <Bar> startinsert<CR>"),
        dashboard.button("f", "⌕  File search", ":lua require('telescope.builtin').find_files({hidden = true})<CR>"),
        -- dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
        dashboard.button("r", "  Recently used files", ":Telescope oldfiles<CR>"),
        dashboard.button("t", "  Text search", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configs", ":e $HOME/.config/nvim/init.lua<CR>"),
        dashboard.button("l", "󰁯  Load session", ":SessionManager load_session<CR>"),
        dashboard.button("d", "  Delete session", ":SessionManager delete_session<CR>"),
        dashboard.button("q", "  Quit", ":qa <CR>")
    },
    opts = {
        spacing = 1,
        hl = "Integrated"
    }
}

local plugins_gen = io.popen('ls $HOME"/.local/share/nvim/site/pack/packer/start" | wc -l | tr -d "\n" ')
local plugins = plugins_gen:read("*a")
plugins_gen:close()

local plugins_text = "   " .. plugins .. " plugins" .. "   v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch

local footer1 = {
    type = "text",
    val = plugins_text,
    opts = {
        position = "center",
        hl = "Include"
    }
}

-- Quote
local fortune = require "alpha.fortune"
local quote = table.concat(fortune(), "\n")

local footer2 = {
    type = "text",
    val = quote,
    opts = {
        position = "center",
        hl = "Type"
    }
}

local alpha_config = {
    layout = {
        { type = "padding", val = 14 },
        header,
        { type = "padding", val = 2 },
        buttons,
        footer1,
        footer2
    },
    -- opts = {
    --     margin = 5,
    -- }
}

-- alpha.setup(dashboard.config)
alpha.setup(alpha_config)
