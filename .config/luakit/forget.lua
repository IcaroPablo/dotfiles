--- Clear what browsing leaves behind: site data (cookies, storage, caches),
-- history, command line history, the closed tabs that u reopens, the
-- downloads list and the favicon cache.
--
--   :forget        keeps the cookies and storage of the sites listed in
--                  keep-cookies (see keep_cookies.lua); their caches go
--   :forget-all    keeps nothing
--
-- What stays: the open tabs, with their back and forward history, downloaded
-- files, bookmarks, quickmarks and the keep-cookies list itself.

local window = require("window")
local modes = require("modes")
local history = require("history")
local downloads = require("downloads")
local session = require("session")
local keep_cookies = require("keep_cookies")

local _M = {}

-- what even a kept site loses: caches, and data meant to last one session
local volatile = { "memory_cache", "disk_cache", "session_storage",
    "hsts_cache", "device_id_hash_salt" }

-- Clears the site data list doesn't keep, or all of it when list is nil, and
-- returns the number of sites kept. Must run in a coroutine, since WebKit
-- clears asynchronously.
local function forget_site_data(list)
    if not list then
        luakit.website_data.clear({ "all" })
        return 0
    end
    luakit.website_data.clear(volatile)
    local n = 0
    for domain in pairs(luakit.website_data.fetch({ "all" })) do
        if keep_cookies.kept(domain, list) then
            n = n + 1
        else
            luakit.website_data.remove({ "all" }, domain)
        end
    end
    return n
end

local function forget_history()
    history.init()
    history.db:exec("DELETE FROM history")
end

local function forget_command_history()
    for _, mode in pairs(modes.get_modes()) do
        local h = mode.history
        if h then
            h.items, h.len, h.cursor, h.orig, h.filtered = {}, 0, nil, nil, nil
        end
    end
    os.remove(luakit.data_dir .. "/command-history")
end

-- undoclose keeps the closed tabs in a local table, which only its own
-- functions reach
local function forget_closed_tabs()
    local undo = window.methods.undo_close_tab
    if not undo then return end
    for i = 1, math.huge do
        local name, closed = debug.getupvalue(undo, i)
        if not name then break end
        if name == "closed_tabs" then
            for tabs in pairs(closed) do closed[tabs] = nil end
            break
        end
    end
    -- the crash recovery session has a copy
    session.save(session.recovery_file)
end

local function forget_downloads()
    downloads.init()
    downloads.db:exec("DELETE FROM downloads")
    -- running downloads stay in the list
    downloads.clear()
end

local function forget(w, list)
    coroutine.wrap(function ()
        local ok, kept = pcall(function ()
            -- the site data goes first: clearing it yields, so by the time
            -- the rest runs, luakit has added this command to the command
            -- history, and it goes too
            local kept = forget_site_data(list)
            forget_history()
            forget_command_history()
            forget_closed_tabs()
            forget_downloads()
            luakit.clear_favicon_database()
            return kept
        end)
        if not w.win then return end
        if not ok then return w:error("Couldn't forget it all: " .. tostring(kept)) end
        if kept > 0 then
            w:notify(string.format("Forgot it all but the cookies and storage of %d kept %s",
                kept, kept == 1 and "site" or "sites"))
        else
            w:notify("Forgot it all")
        end
    end)()
end

modes.add_cmds({
    { ":forget", "Clear site data, history and the rest, keeping the sites in keep-cookies.",
        function (w) forget(w, keep_cookies.read_list() or {}) end },
    { ":forget-all", "Clear site data, history and the rest, keep-cookies sites included.",
        function (w) forget(w, nil) end },
})

return _M

-- vim: et:sw=4:ts=8:sts=4
