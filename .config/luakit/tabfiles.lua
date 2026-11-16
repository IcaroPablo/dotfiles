--- Tab files: a window's tabs kept in a plain text file, one URI per line,
-- the way an editor keeps a buffer in a file.
--
--   :te[dit] <file>        open the file's tabs in a window bound to it
--   :te[dit][!]            reread the bound file (! drops unsaved changes)
--   :tw[rite][!] [file]    write the tabs to the bound file, or to <file>,
--                          which the window is then bound to
--   :tadd <file>           add the current page to a tab file, without
--                          opening the file; one open in a window gets it
--                          as a tab
--
-- Relative paths are under ~/Workspace. Tabs other than the first load when
-- first shown. A bound window's title starts with [file], and [file +] while
-- its tabs differ from the file; such a window closes only with :q!.
--
-- The file name completes a directory at a time, as in a shell, offering
-- the tab files and the directories that hold some. :open, :tabopen and
-- :winopen also offer the links in every tab file, matching any part of the
-- link or of the file's path. luakit://tabfiles/ (tabfiles_page.lua) lists
-- them all.
--
-- A tab file is a file under ~/Workspace with a URI on every line that isn't
-- blank, outside dot directories and git work trees.

local window = require("window")
local webview = require("webview")
local modes = require("modes")
local session = require("session")
local settings = require("settings")
local completion = require("completion")
local lousy = require("lousy")

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

-- path relative to _M.dir, or short(path) when it's outside
local function relative(path)
    if path:sub(1, #_M.dir + 1) == _M.dir .. "/" then return path:sub(#_M.dir + 2) end
    return short(path)
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

local function has(uris, uri)
    for _, u in ipairs(uris) do
        if u == uri then return true end
    end
    return false
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

-- Writes text to path through a temporary file, so a failed write leaves the
-- file as it was. Returns true, or nil and the reason.
local function save(path, text)
    local tmp = path .. ".new"
    local fh, err = io.open(tmp, "w")
    local ok = fh and fh:write(text)
    ok = fh and fh:close() and ok
    if ok then ok, err = os.rename(tmp, path) end
    if not ok then
        os.remove(tmp)
        return nil, err and (err:gsub("^.-: ", ""))
    end
    return true
end

local function cant_write(path, err)
    return "Can't write " .. short(path) .. (err and ": " .. err or "")
end

local function modified(w)
    return bound[w] and text_of(tabs_of(w)) ~= bound[w].saved
end

local function window_of(path)
    for w, f in pairs(bound) do
        if f.path == path and w.win then return w end
    end
end

-- The tab files

-- a regular file of at most 1 MiB with a URI on every line that isn't blank,
-- and at least one
local function is_tab_file(path)
    if (lfs.attributes(path, "size") or math.huge) > 1024 * 1024 then return false end
    local fh = io.open(path, "r")
    if not fh then return false end
    local uris = 0
    for line in fh:lines() do
        if line:find("%S") then
            if not line:match("^%s*%a[%w+.-]*:%S+%s*$") then uris = 0; break end
            uris = uris + 1
        end
    end
    fh:close()
    return uris > 0
end

local function walk(dir, depth, list)
    local ok, iter, state = pcall(lfs.dir, dir)
    if not ok or depth > 8 then return end
    local names = {}
    for name in iter, state do
        if name:sub(1, 1) ~= "." then names[#names + 1] = name end
    end
    table.sort(names)
    for _, name in ipairs(names) do
        local path = dir .. "/" .. name
        local mode = lfs.symlinkattributes(path, "mode")
        if mode == "directory" then
            if not lfs.attributes(path .. "/.git") then walk(path, depth + 1, list) end
        elseif mode == "file" and is_tab_file(path) then
            list[#list + 1] = path
        end
    end
end

-- the last search, which serves for 10 seconds unless a file is written
local found, found_at

local function rescan() found = nil end

--- The paths of the tab files, sorted.
function _M.files()
    if not found or os.time() - found_at >= 10 then
        found = {}
        walk(_M.dir, 1, found)
        found_at = os.time()
    end
    return found
end

--- Every tab file, as { path, dir, name, bound, uris }, sorted by directory
-- (relative to the tab file directory, "" for itself) and then by name; bound
-- is whether the file is open in a window.
function _M.list()
    rescan()
    local list = {}
    for _, path in ipairs(_M.files()) do
        local dir, name = relative(path):match("^(.-)/?([^/]*)$")
        list[#list + 1] = { path = path, dir = dir, name = name,
            bound = window_of(path) ~= nil, uris = uris_of(read(path)) }
    end
    table.sort(list, function (a, b)
        if a.dir ~= b.dir then return a.dir < b.dir end
        return a.name < b.name
    end)
    return list
end

-- Opening and writing

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

--- Opens the tab file at path as :te would from w.
function _M.edit(w, path) edit(w, { arg = path }) end

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
    local ok, err = save(path, text)
    if not ok then return w:error(cant_write(path, err)) end
    rescan()
    bound[w] = { path = path, saved = text }
    w:update_win_title()
    w:notify(string.format('"%s" %s written', short(path), count(uris)))
end

local function add(w, o)
    local uri = w.view.uri
    if is_blank(uri) then return w:error("No page in this tab") end
    if not o.arg then return w:error("No file name (:tadd <file>)") end
    local path = resolve(o.arg)

    -- a file open in a window gets the page as a tab there; the file is
    -- written too, unless the window or the file has changes of its own
    local owner = window_of(path)
    if owner then
        if has(tabs_of(owner), uri) then
            return w:notify(string.format('"%s" already has this page', short(path)))
        end
        local f = bound[owner]
        local clean = not modified(owner) and text_of(uris_of(read(path))) == f.saved
        add_lazy_tab(owner, uri)
        if clean then
            local text = text_of(tabs_of(owner))
            local ok, err = save(path, text)
            if not ok then return w:error(cant_write(path, err)) end
            f.saved = text
        end
        return w:notify(string.format('Added to "%s", %s%s', short(path), count(tabs_of(owner)),
            clean and "" or " (:tw in its window writes it)"))
    end

    local text = read(path) or ""
    local uris = uris_of(text)
    if has(uris, uri) then
        return w:notify(string.format('"%s" already has this page', short(path)))
    end
    if text ~= "" and text:sub(-1) ~= "\n" then text = text .. "\n" end
    local ok, err = save(path, text .. uri .. "\n")
    if not ok then return w:error(cant_write(path, err)) end
    rescan()
    uris[#uris + 1] = uri
    w:notify(string.format('Added to "%s", %s', short(path), count(uris)))
end

--- Removes the first line that is uri from the tab file at path. Returns
-- nothing, or the reason it couldn't. A file open in a window is left alone:
-- the window is where it changes.
function _M.remove(path, uri)
    if window_of(path) then return short(path) .. " is open in a window; close the tab there" end
    local text = read(path)
    if not text then return "Can't read " .. short(path) end
    if text ~= "" and text:sub(-1) ~= "\n" then text = text .. "\n" end
    local lines, removed = {}, false
    for line in text:gmatch("([^\n]*)\n") do
        if not removed and line:match("^%s*(.-)%s*$") == uri then
            removed = true
        else
            lines[#lines + 1] = line
        end
    end
    if not removed then return short(path) .. " doesn't have " .. uri end
    local ok, err = save(path, #lines > 0 and table.concat(lines, "\n") .. "\n" or "")
    if not ok then return cant_write(path, err) end
    rescan()
end

-- Completion. Only luakit builds with completion.completers can add a group
-- (IcaroPablo/luakit, branch completion-groups).

local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

-- The entries of dir, a directory as typed: under the tab file directory,
-- its tab files and the directories that hold some, as name -> path, the
-- path being nil for a directory, whose name ends with a slash. Elsewhere,
-- all of them, but for dot files.
local function entries(dir)
    local abs = resolve(dir):match("^(.-)/*$") .. "/"
    local list = {}
    if abs:sub(1, #_M.dir + 1) == _M.dir .. "/" then
        for _, path in ipairs(_M.files()) do
            if path:sub(1, #abs) == abs then
                local rest = path:sub(#abs + 1)
                local sub = rest:match("^[^/]*/")
                if sub then list[sub] = false else list[rest] = path end
            end
        end
    else
        local ls = io.popen("ls -1p -- " .. quote(abs) .. " 2>/dev/null")
        for entry in ls:lines() do list[entry] = false end
        ls:close()
    end
    return list
end

local format
if completion.completers then
    -- the entries of the directory typed so far that start with the rest
    completion.completers.tabfile = {
        header = { "Tab file", "" },
        func = function (buf)
            local dir, name = buf:match("^(.-)([^/]*)$")
            local names = {}
            for entry, path in pairs(entries(dir)) do
                if entry:sub(1, #name) == name then names[#names + 1] = { entry, path } end
            end
            table.sort(names, function (a, b) return a[1] < b[1] end)
            local rows = {}
            for _, e in ipairs(names) do
                local entry = dir .. e[1]
                local tabs = e[2] and count(uris_of(read(e[2]))) or ""
                rows[#rows + 1] = { lousy.util.escape(entry), tabs, format = {{ lit = entry }}, buf = entry }
            end
            return rows
        end,
    }
    format = "{tabfile}"

    -- the links in every tab file whose link or path has all the words typed
    completion.completers.tablink = {
        header = { "Tab file", "URI" },
        func = function (buf)
            local words = {}
            for word in buf:lower():gmatch("%S+") do words[#words + 1] = word end
            if #words == 0 then return {} end
            local max = settings.get_setting("completion.max_items")
            local rows = {}
            for _, path in ipairs(_M.files()) do
                local rel = relative(path)
                for _, uri in ipairs(uris_of(read(path))) do
                    local text = (uri .. " " .. rel):lower()
                    local all = true
                    for _, word in ipairs(words) do
                        if not text:find(word, 1, true) then all = false; break end
                    end
                    if all then
                        rows[#rows + 1] = { lousy.util.escape(rel), lousy.util.escape(uri),
                            format = {{ lit = uri }}, buf = uri }
                        if #rows >= max then return rows end
                    end
                end
            end
            return rows
        end,
    }

    local uri_groups = completion.completers.uri.func
    completion.completers.uri.func = function (...)
        local groups = uri_groups(...)
        groups[#groups + 1] = { format = "{tablink}" }
        return groups
    end
end

modes.add_cmds({
    { ":te[dit]", "Open a tab file in a window bound to it, or reread the bound one.",
        { func = edit, format = format } },
    { ":tw[rite]", "Write the window's tabs to its tab file, or to a new one.",
        { func = write, format = format } },
    { ":tadd", "Add the current page to a tab file, without opening the file.",
        { func = add, format = format } },
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
