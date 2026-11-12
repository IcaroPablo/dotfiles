-- Loaded by luakit's own rc.lua (/etc/xdg/luakit/rc.lua) after its modules.

local settings = require "settings"
local modes = require "modes"

-- sites' dark CSS (prefers-color-scheme) and dark GTK widgets; needs a restart
settings.set_setting("application.prefer_dark_mode", true)

-- what :open and :tabopen search for text that isn't an address
local engines = settings.get_setting("window.search_engines")
engines.kagi = "https://kagi.com/search?q=%s"
settings.set_setting("window.search_engines", engines)
settings.set_setting("window.default_search_engine", "kagi")

-- J and K as in Vimium: J goes one tab left, K one tab right
modes.remove_binds("normal", { "J", "K" })
modes.add_binds("normal", {
    { "J", "Go to previous tab.", function (w) w:prev_tab() end },
    { "K", "Go to next tab.", function (w) w:next_tab() end },
})

-- yanks go to the clipboard as well, not only to the primary selection
local function yank(w, text, what)
    luakit.selection.primary = text
    luakit.selection.clipboard = text
    w:notify("Yanked " .. what .. ": " .. text, false)
end

modes.remove_binds("normal", { "y" })
modes.add_binds("normal", {
    { "y", "Yank the current URI.", function (w)
        yank(w, ((w.view.uri or ""):gsub(" ", "%%20")), "uri")
    end },
})

modes.remove_binds("ex-follow", { "y", "Y" })
modes.add_binds("ex-follow", {
    { "y", "Hint links and yank the chosen one's URI.", function (w)
        w:set_mode("follow", { prompt = "yank", selector = "uri", evaluator = "uri",
            func = function (uri) yank(w, (uri:gsub(" ", "%%20"):gsub("^mailto:", "")), "uri") end })
    end },
    { "Y", "Hint links and yank the chosen one's text.", function (w)
        w:set_mode("follow", { prompt = "yank desc", selector = "desc", evaluator = "desc",
            func = function (desc) yank(w, desc, "desc") end })
    end },
})

require "tabfiles"
require "keep_cookies"
require "adblock_update"
require "adblock_hide"
require "playback"
