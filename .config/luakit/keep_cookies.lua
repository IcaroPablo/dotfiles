--- Cookies and site storage last one session, except for the domains listed
-- one per line in ~/.local/share/luakit/keep-cookies, which keep theirs: like
-- Chromium's "clear on exit" with its allowed sites, only done at start, and
-- pages wait for it before loading. With no list file, nothing is cleared.
--
--   :keep-cookies    adds the current site's registrable domain to the list
--
-- WebKit groups site data by registrable domain, so github.com in the list
-- also keeps gist.github.com's, and gist.github.com keeps all of github.com's.
-- :keep-cookies takes the domain from WebKit's record of the site's data; for
-- a site with no data yet, it writes the host instead.

local webview = require("webview")
local modes = require("modes")
local lousy = require("lousy")

local _M = {}

_M.file = luakit.data_dir .. "/keep-cookies"
_M.types = { "cookies", "local_storage", "indexeddb_databases",
    "offline_application_cache", "plugin_data" }

local function read_list()
    local fh = io.open(_M.file, "r")
    if not fh then return nil end
    local list = {}
    for line in fh:lines() do
        local domain = line:match("^%s*([^%s#]+)")
        if domain then list[#list + 1] = domain:lower() end
    end
    fh:close()
    return list
end

local function related(a, b)
    return a == b or a:sub(-#b - 1) == "." .. b or b:sub(-#a - 1) == "." .. a
end

local function kept(domain, list)
    for _, d in ipairs(list) do
        if related(domain, d) then return true end
    end
    return false
end

-- the name of WebKit's site data record for host, which is its registrable
-- domain; nil when the site has stored nothing yet
local function site_of(host)
    for name in pairs(luakit.website_data.fetch(_M.types)) do
        if host == name or host:sub(-#name - 1) == "." .. name then return name end
    end
end

local list = read_list()
local blocked = setmetatable({}, { __mode = "k" })
local purging = list ~= nil

webview.add_signal("init", function (view)
    if purging then
        blocked[view] = true
        webview.modify_load_block(view, "keep_cookies", true)
    end
end)

if purging then
    coroutine.wrap(function ()
        local ok, err = pcall(function ()
            local data = luakit.website_data.fetch(_M.types)
            for domain in pairs(data) do
                if not kept(domain, list) then
                    luakit.website_data.remove(_M.types, domain)
                end
            end
        end)
        if not ok then msg.error("keep_cookies: %s", err) end
        purging = false
        for view in pairs(blocked) do
            webview.modify_load_block(view, "keep_cookies", false)
        end
    end)()
end

modes.add_cmds({
    { ":keep-cookies", "Keep the current site's cookies and storage between sessions.",
        function (w)
            local uri = w.view.uri and lousy.uri.parse(w.view.uri)
            local host = uri and uri.host and uri.host:lower()
            if not host or host == "" then return w:error("No site in this tab") end
            coroutine.wrap(function ()
                local domain = site_of(host) or host:gsub("^www%.", "")
                if not w.win then return end
                if kept(domain, read_list() or {}) then
                    return w:notify(domain .. " already keeps its cookies")
                end
                local fh, err = io.open(_M.file, "a")
                if not fh then return w:error(err) end
                fh:write(domain, "\n")
                fh:close()
                w:notify(domain .. " keeps its cookies from now on")
            end)()
        end },
})

return _M

-- vim: et:sw=4:ts=8:sts=4
