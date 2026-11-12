--- Element hiding for the ad blocker: the ## rules of the enabled filter
-- lists, which luakit's own adblock module skips.
--
-- Generic rules (##.ad) go into one stylesheet shared by every http(s) page;
-- site rules (example.com##.ad, google.*##.ad) go into one per site, made the
-- first time the site is opened. Exceptions (example.com#@#.ad) and the
-- $elemhide and $generichide options of @@ rules are followed. Extended
-- syntax (#?#, #$#, scriptlets, :has-text and the like) is skipped. The rules
-- are read again whenever the adblock module reloads its lists.

local adblock = require("adblock")
local window = require("window")
local webview = require("webview")
local lousy = require("lousy")

local _M = {}

local dir = luakit.data_dir .. "/adblock/"

-- functional pseudo-classes CSS has; any other one is a filter-list extension
local css_functions = {
    ["not"] = true, is = true, where = true, has = true, lang = true, dir = true,
    ["nth-child"] = true, ["nth-last-child"] = true,
    ["nth-of-type"] = true, ["nth-last-of-type"] = true,
}

-- an unclosed [ ( or quote would swallow every rule after it in the sheet
local function balanced(selector)
    local depth, quote = 0, nil
    for c in selector:gmatch(".") do
        if quote then
            if c == quote then quote = nil end
        elseif c == '"' or c == "'" then
            quote = c
        elseif c == "[" or c == "(" then
            depth = depth + 1
        elseif c == "]" or c == ")" then
            depth = depth - 1
            if depth < 0 then return false end
        end
    end
    return depth == 0 and not quote
end

local function plain_css(selector)
    if selector:find("^[+^]") or selector:find("[{}\\]") or selector:find("/*", 1, true) then
        return false
    end
    for name in selector:gmatch(":([%a-]+)%(") do
        if not css_functions[name] then return false end
    end
    return not selector:find("[%[%(\"']") or balanced(selector)
end

local rules

local function add(t, key, selector)
    local list = t[key]
    if not list then list = {}; t[key] = list end
    list[#list + 1] = selector
end

local function each(list, f)
    for _, s in ipairs(list or {}) do f(s) end
end

local function parse_hiding(domains, kind, selector)
    if not plain_css(selector) then return end
    if domains == "" then
        if kind == "@" then
            rules.generic_exceptions[selector] = true
        else
            rules.generic[#rules.generic + 1] = selector
        end
        return
    end
    local suffix = kind == "@" and "_exceptions" or ""
    for domain in domains:lower():gmatch("[^,]+") do
        -- "google.*" is an entity: google.com, google.co.uk and so on
        local entity = domain:match("^([%w-]+)%.%*$")
        if entity then
            add(rules["entities" .. suffix], entity, selector)
        elseif domain:find("^[%w.-]+$") then
            add(rules["sites" .. suffix], domain, selector)
        end
    end
end

-- @@||example.com^$generichide turns off a kind of hiding on a site
local function parse_exception(line)
    local pattern, opts = line:match("^@@([^$]*)%$(.+)$")
    if not pattern then return end
    pattern = pattern:gsub("^|?|?", ""):gsub("^%a*://", "")
    local host = pattern:match("^([%w.-]+)")
    if not host or host:find("%.$") then return end
    for opt in opts:gmatch("[^,]+") do
        if opt == "elemhide" or opt == "ehide" then
            rules.no_hiding[host:lower()] = true
        elseif opt == "generichide" or opt == "ghide" then
            rules.no_generic[host:lower()] = true
        end
    end
end

local function parse_file(path)
    local fh = io.open(path, "r")
    if not fh then return end
    for line in fh:lines() do
        local first = line:sub(1, 1)
        if first ~= "!" and first ~= "[" then
            local domains, kind, selector = line:match("^([^#]*)#(@?)#(.+)$")
            if domains then
                parse_hiding(domains, kind, selector)
            elseif first == "@" then
                parse_exception(line)
            end
        end
    end
    fh:close()
end

-- WebKit reads the generic sheet again for every page (60 ms or so); 20
-- selectors to a rule makes it half the size of one rule each, and a selector
-- WebKit can't read only takes its rule's other 19 with it
local function css(selectors, skip)
    local out, group, seen, n = {}, {}, {}, 0
    local function flush()
        out[#out + 1] = table.concat(group, ",") .. "{display:none!important}"
        group = {}
    end
    for _, s in ipairs(selectors) do
        if not seen[s] and not skip[s] then
            seen[s] = true
            n = n + 1
            group[#group + 1] = s
            if #group == 20 then flush() end
        end
    end
    if #group > 0 then flush() end
    return n > 0 and table.concat(out, "\n") or nil, n
end

local generic_sheet
local by_host = {}

local function load()
    rules = {
        generic = {}, generic_exceptions = {},
        sites = {}, sites_exceptions = {},
        entities = {}, entities_exceptions = {},
        no_hiding = {}, no_generic = {},
    }
    local files = {}
    for name, list in pairs(adblock.rules) do
        if lousy.util.table.hasitem(list.opts or {}, "Enabled") then files[#files + 1] = name end
    end
    table.sort(files)
    for _, name in ipairs(files) do parse_file(dir .. name) end

    local source, n = css(rules.generic, rules.generic_exceptions)
    generic_sheet = source and stylesheet{ source = source }
    by_host = {}
    _M.generic, _M.sites = n, 0
    for _ in pairs(rules.sites) do _M.sites = _M.sites + 1 end
end

-- the stylesheets for a host: { generic sheet or nil, site sheet or nil }
local function sheets_for(host)
    if by_host[host] then return by_host[host] end
    local site, except, no_generic = {}, {}, false
    local d = host
    while d do
        if rules.no_hiding[d] then by_host[host] = {}; return by_host[host] end
        no_generic = no_generic or rules.no_generic[d]
        local entity = d:match("^([^.]+)%.")
        local function keep(s) site[#site + 1] = s end
        local function drop(s) except[s] = true end
        each(rules.sites[d], keep)
        each(rules.sites_exceptions[d], drop)
        if entity then
            each(rules.entities[entity], keep)
            each(rules.entities_exceptions[entity], drop)
        end
        d = d:match("%.(.+)")
    end

    local generic = not no_generic and generic_sheet or nil
    if generic and next(except) then
        -- an exception to a generic rule needs a copy of the generic sheet
        for _, s in ipairs(rules.generic) do
            if except[s] then
                local skip = setmetatable({}, { __index = function (_, k)
                    return except[k] or rules.generic_exceptions[k]
                end })
                local source = css(rules.generic, skip)
                generic = source and stylesheet{ source = source }
                break
            end
        end
    end
    local source = css(site, except)
    by_host[host] = { generic, source and stylesheet{ source = source } }
    return by_host[host]
end

local applied = setmetatable({}, { __mode = "k" })

local function apply(view)
    local uri = view.uri and lousy.uri.parse(view.uri)
    local host = uri and (uri.scheme == "http" or uri.scheme == "https") and uri.host
    local want = (host and adblock.enabled) and sheets_for(host:lower()) or {}
    local had = applied[view] or {}
    for i = 1, 2 do
        if had[i] and had[i] ~= want[i] then view.stylesheets[had[i]] = false end
    end
    for i = 1, 2 do
        if want[i] and want[i] ~= had[i] then view.stylesheets[want[i]] = true end
    end
    applied[view] = want
end

webview.add_signal("init", function (view)
    view:add_signal("stylesheet", apply)
end)

-- adblock calls this after reloading its lists, but before it updates a
-- list's Enabled flag, so the rules are read again once that's done
local refresh_views = adblock.refresh_views
adblock.refresh_views = function (...)
    refresh_views(...)
    luakit.idle_add(function ()
        load()
        for _, w in pairs(window.bywidget) do
            for _, view in ipairs(w.tabs.children) do apply(view) end
        end
        return false
    end)
end

load()

return _M

-- vim: et:sw=4:ts=8:sts=4
