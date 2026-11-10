--- Tab files: a window's tabs kept in a plain text file, one URI per line,
-- the way an editor keeps a buffer in a file.
--
--   :te[dit] <file>        open the file's tabs in a window bound to it
--   :te[dit][!]            reread the bound file (! drops unsaved changes)
--   :tw[rite][!] [file]    write the tabs to the bound file, or to <file>,
--                          which the window is then bound to
--
-- Relative paths are under ~/Workspace. Tabs other than the first load when
-- first shown. A bound window's title starts with [file], and [file +] while
-- its tabs differ from the file; such a window closes only with :q!.

local window = require("window")
local webview = require("webview")
local modes = require("modes")
local session = require("session")
local settings = require("settings")

local _M = {}

local home = os.getenv("HOME")
_M.dir = home .. "/Workspace"

-- window -> { path, saved }: saved is the file as last read or written, as
-- the text the window's tabs would write
local bound = setmetatable({}, { __mode = "k" })

local function resolve(path)
    if path:sub(1, 2) == "~/" then return home .. path:sub(2) end
    if path:sub(1, 1) == "/" then return path end
    return _M.dir .. "/" .. path
end

local function short(path)
    if path:sub(1, #home + 1) == home .. "/" then return "~" .. path:sub(#home + 1) end
    return path
end

local function is_blank(uri)
    return not uri or uri == "" or uri == "about:blank"
        or uri == settings.get_setting("window.new_tab_page")
end

local function uris_of(text)
    local uris = {}
    for line in (text or ""):gmatch("[^\n]+") do
        local uri = line:match("^%s*(.-)%s*$")
        if not is_blank(uri) then uris[#uris + 1] = uri end
    end
    return uris
end

local function text_of(uris)
    return #uris > 0 and table.concat(uris, "\n") .. "\n" or ""
end

local function tabs_of(w)
    local uris = {}
    for _, view in ipairs(w.tabs.children) do
        if not view.private and not is_blank(view.uri) then uris[#uris + 1] = view.uri end
    end
    return uris
end

local function count(uris)
    return #uris == 1 and "1 tab" or #uris .. " tabs"
end

local function read(path)
    local fh = io.open(path, "r")
    if not fh then return nil end
    local text = fh:read("*a")
    fh:close()
    return text
end

local function modified(w)
    return bound[w] and text_of(tabs_of(w)) ~= bound[w].saved
end

local function window_of(path)
    for w, f in pairs(bound) do
        if f.path == path and w.win then return w end
    end
end

-- unbound, and showing nothing but blank or home pages
local function is_scratch(w)
    if bound[w] then return false end
    local home_page = settings.get_setting("window.home_page")
    for _, view in ipairs(w.tabs.children) do
        if not is_blank(view.uri) and view.uri ~= home_page then return false end
    end
    return true
end

local function append() return -1 end

local function add_lazy_tab(w, uri)
    local view = w:new_tab(settings.get_setting("window.new_tab_page"), { switch = false, order = append })
    webview.modify_load_block(view, "tabfiles", true)
    webview.set_location(view, { uri = uri })
    local function unblock(v)
        webview.modify_load_block(v, "tabfiles", false)
        v:remove_signal("switched-page", unblock)
    end
    view:add_signal("switched-page", unblock)
end

-- Shows uris in w, replacing its tabs, or in a new window if w is nil.
local function show(w, uris)
    local first = uris[1] or settings.get_setting("window.new_tab_page")
    if w then
        local old = {}
        for i, view in ipairs(w.tabs.children) do old[i] = view end
        w:new_tab(first, { switch = true, order = append })
        for i = 2, #uris do add_lazy_tab(w, uris[i]) end
        for _, view in ipairs(old) do w:close_tab(view) end
    else
        w = window.new({ first })
        for i = 2, #uris do add_lazy_tab(w, uris[i]) end
    end
    return w
end

local function edit(w, o)
    local f = bound[w]
    local path = o.arg and resolve(o.arg) or (f and f.path)
    if not path then return w:error("No file name (:te <file>)") end
    local owner = window_of(path)
    if owner and owner ~= w then return w:error(short(path) .. " is open in another window") end
    if owner == w and not o.bang and modified(w) then
        return w:error("Unsaved changes (:tw writes them, :te! drops them)")
    end

    local text = read(path)
    local uris = uris_of(text)
    w = show((owner == w or is_scratch(w)) and w or nil, uris)
    bound[w] = { path = path, saved = text_of(uris) }
    w:update_win_title()
    w:notify(string.format('"%s" %s', short(path), text and count(uris) or "[New]"))
end

local function write(w, o)
    local f = bound[w]
    local path = o.arg and resolve(o.arg) or (f and f.path)
    if not path then return w:error("No file name (:tw <file>)") end
    local owner = window_of(path)
    if owner and owner ~= w then return w:error(short(path) .. " is open in another window") end

    local disk = read(path)
    if not o.bang then
        if owner == w and text_of(uris_of(disk)) ~= f.saved then
            return w:error(short(path) .. " changed since read (:te! rereads it, :tw! overwrites it)")
        elseif owner ~= w and disk then
            return w:error(short(path) .. " exists (:tw! overwrites it)")
        end
    end

    local uris = tabs_of(w)
    local text = text_of(uris)
    local tmp = path .. ".new"
    local fh, err = io.open(tmp, "w")
    local ok = fh and fh:write(text)
    ok = fh and fh:close() and ok
    if ok then ok, err = os.rename(tmp, path) end
    if not ok then
        os.remove(tmp)
        return w:error("Can't write " .. short(path) .. (err and ": " .. err:gsub("^.-: ", "") or ""))
    end
    bound[w] = { path = path, saved = text }
    w:update_win_title()
    w:notify(string.format('"%s" %s written', short(path), count(uris)))
end

modes.add_cmds({
    { ":te[dit]", "Open a tab file in a window bound to it, or reread the bound one.", edit },
    { ":tw[rite]", "Write the window's tabs to its tab file, or to a new one.", write },
})

local update_win_title = window.methods.update_win_title
window.methods.update_win_title = function (w)
    update_win_title(w)
    local f = bound[w]
    if f then
        local name = f.path:match("[^/]*$")
        w.win.title = string.format("[%s%s] %s", name, modified(w) and " +" or "", w.win.title)
    end
end

local close_win = window.methods.close_win
window.methods.close_win = function (w, force)
    if not force and modified(w) then
        w:error(short(bound[w].path) .. " has unsaved changes (:tw writes them, :q! drops them)")
        return false
    end
    return close_win(w, force)
end

window.add_signal("init", function (w)
    w:add_signal("close", function () bound[w] = nil end)
    -- tabs added, closed or moved in the background don't retitle the window
    local function retitle()
        luakit.idle_add(function () if w.win then w:update_win_title() end end)
    end
    w.tabs:add_signal("page-added", retitle)
    w.tabs:add_signal("page-removed", retitle)
    w.tabs:add_signal("page-reordered", retitle)
end)

-- Luakit's own session (crash recovery, :wq) keeps each window's binding.
session.add_signal("save", function (state)
    for w, ws in pairs(state) do
        if bound[w] then ws.tabfile = bound[w].path end
    end
end)

session.add_signal("restore", function (state)
    for w, ws in pairs(state) do
        if ws.tabfile then
            bound[w] = { path = ws.tabfile, saved = text_of(uris_of(read(ws.tabfile))) }
            w:update_win_title()
        end
    end
end)

return _M

-- vim: et:sw=4:ts=8:sts=4
