--- Tab files: a window's tabs kept in a plain text file, one URI per line,
-- the way an editor keeps a buffer in a file.
--
--   :te[dit] <file>        open the file's tabs in a window bound to it
--   :te[dit][!]            reread the bound file (! drops unsaved changes)
--   :tw[rite][!] [file]    write the tabs to the bound file, or to <file>,
--                          which the window is then bound to
--   :tadd [file]           add the current page to a tab file, without
--                          opening the file; one open in a window gets it
--                          as a tab. With no file, pick one; a name that
--                          matches none makes a new file
--   :tabfiles [query]      pick links from every tab file (gb does it too),
--                          by fuzzy search on the file's path and the link's
--                          title and URI:
--                            enter    open here (the rest in new tabs)
--                            ctrl-t   open in new tabs
--                            ctrl-w   open in a new window
--                            ctrl-o   open the link's whole file, as :te
--                            ctrl-x   take the links out of their files
--                            tab      select more than one
--
-- Relative paths are under ~/Workspace/tabfiles, the tab files' home. Tabs
-- other than the first load when first shown. A bound window's title starts
-- with [file], and [file +] while its tabs differ from the file; such a
-- window closes only with :q!.
--
-- The file name completes a directory at a time, as in a shell, offering
-- the tab files and the directories that hold some. Picking runs fzf through
-- fzfmenu (the dotfiles' bin/), in a floating st window.
--
-- A tab file is a file under ~/Workspace/tabfiles with a URI starting every
-- line that isn't blank, outside dot directories and git work trees. After
-- the URI and a space comes the page's title, which :tw and :tadd write: a
-- tab not loaded yet keeps the one its file gave it. Whether a window has
-- unsaved changes depends on its URIs only, as titles change by themselves.
-- The picker closes with the window that opened it.

local window = require("window")
local webview = require("webview")
local modes = require("modes")
local session = require("session")
local settings = require("settings")
local completion = require("completion")
local lousy = require("lousy")

local _M = {}

local home = os.getenv("HOME")
_M.dir = home .. "/Workspace/tabfiles"

-- window -> { path, saved, titles }: saved is the file's URIs as last read or
-- written, as text_of gives them, and titles its titles, by URI
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

-- A line of a tab file is a URI, then, after a space, the page's title, if
-- known. Returns the lines of text as { uri, title }, title being nil when
-- the line has none.
local function entries_of(text)
    local entries = {}
    for line in (text or ""):gmatch("[^\n]+") do
        local uri, title = line:match("^%s*(%S+)%s*(.-)%s*$")
        if not is_blank(uri) then
            entries[#entries + 1] = { uri = uri, title = title ~= "" and title or nil }
        end
    end
    return entries
end

local function uris_of(text)
    local uris = {}
    for i, e in ipairs(entries_of(text)) do uris[i] = e.uri end
    return uris
end

local function titles_of(text)
    local titles = {}
    for _, e in ipairs(entries_of(text)) do titles[e.uri] = e.title end
    return titles
end

-- a title as a tab file keeps it: on one line, and nil when it says nothing
-- the URI doesn't
local function clean_title(title, uri)
    title = title and (title:gsub("%s+", " "):match("^ ?(.-) ?$"))
    if title == "" or title == uri then return nil end
    return title
end

local function line_of(uri, title)
    return title and uri .. " " .. title or uri
end

-- the URIs as text, one per line: what tells whether a window and its file
-- have the same tabs, whatever their titles
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

-- The text w's tabs write: a tab's title is the page's once it has loaded,
-- and until then the one in known (URI -> title).
local function render(w, known)
    local lines = {}
    for _, view in ipairs(w.tabs.children) do
        if not view.private and not is_blank(view.uri) then
            local title = not webview.has_load_block(view) and clean_title(view.title, view.uri)
            lines[#lines + 1] = line_of(view.uri, title or known[view.uri])
        end
    end
    return #lines > 0 and table.concat(lines, "\n") .. "\n" or ""
end

local function merge(...)
    local all = {}
    for i = 1, select("#", ...) do
        for k, v in pairs(select(i, ...) or {}) do all[k] = v end
    end
    return all
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

-- a regular file of at most 1 MiB with a URI starting every line that isn't
-- blank, and at least one
local function is_tab_file(path)
    if (lfs.attributes(path, "size") or math.huge) > 1024 * 1024 then return false end
    local fh = io.open(path, "r")
    if not fh then return false end
    local uris = 0
    for line in fh:lines() do
        if line:find("%S") then
            if not line:match("^%s*%a[%w+.-]*:%S") then uris = 0; break end
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
    bound[w] = { path = path, saved = text_of(uris), titles = titles_of(text) }
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

    -- a tab not loaded yet keeps the title its file, or this one, gave it
    local uris = tabs_of(w)
    local text = render(w, merge(titles_of(disk), f and f.titles))
    local ok, err = save(path, text)
    if not ok then return w:error(cant_write(path, err)) end
    rescan()
    bound[w] = { path = path, saved = text_of(uris), titles = titles_of(text) }
    w:update_win_title()
    w:notify(string.format('"%s" %s written', short(path), count(uris)))
end

-- Adds uri, with its title, to the tab file name, telling w how it went.
local function add_to(w, uri, title, name)
    local path = resolve(name)

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
        f.titles[uri] = title
        if clean then
            local text = render(owner, f.titles)
            local ok, err = save(path, text)
            if not ok then return w:error(cant_write(path, err)) end
            f.saved = text_of(tabs_of(owner))
            f.titles = titles_of(text)
        end
        return w:notify(string.format('Added to "%s", %s%s', short(path), count(tabs_of(owner)),
            clean and "" or " (:tw in its window writes it)"))
    end

    local text = read(path)
    local uris = uris_of(text)
    if has(uris, uri) then
        return w:notify(string.format('"%s" already has this page', short(path)))
    end
    local new = not text
    text = text or ""
    if text ~= "" and text:sub(-1) ~= "\n" then text = text .. "\n" end
    local ok, err = save(path, text .. line_of(uri, title) .. "\n")
    if not ok then return w:error(cant_write(path, err)) end
    rescan()
    uris[#uris + 1] = uri
    w:notify(string.format('Added to "%s"%s, %s', short(path), new and " [New]" or "", count(uris)))
end

-- Removes the first line with uri from the tab file at path. Returns nothing,
-- or the reason it couldn't. A file open in a window is left alone: the
-- window is where it changes.
local function remove_link(path, uri)
    if window_of(path) then return short(path) .. " is open in a window; close the tab there" end
    local text = read(path)
    if not text then return "Can't read " .. short(path) end
    if text ~= "" and text:sub(-1) ~= "\n" then text = text .. "\n" end
    local lines, removed = {}, false
    for line in text:gmatch("([^\n]*)\n") do
        if not removed and line:match("^%s*(%S*)") == uri then
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

local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

-- Picking, with fzf

--- The picker window's size, in columns and rows: 250 columns of st's 6
-- pixels make it 1560 pixels wide, for paths of up to 65 characters
-- followed by links of up to 180.
_M.picker_size = "250x30"

-- window -> the process group of the picker it opened, which closes with it
local pickers = setmetatable({}, { __mode = "k" })

local function close_picker(w)
    if pickers[w] then os.execute("kill -TERM -- -" .. pickers[w] .. " 2>/dev/null") end
    pickers[w] = nil
end

-- Runs fzfmenu on lines, with the fzf options given, and calls done with the
-- lines fzf printed, none when it was cancelled.
local function pick(w, lines, opts, done)
    close_picker(w)
    local input, output = os.tmpname(), os.tmpname()
    local fh = io.open(input, "w")
    fh:write(table.concat(lines, "\n"), "\n")
    fh:close()
    -- fzfmenu has sh parse its arguments again, so each is quoted twice
    local args = {}
    for i, opt in ipairs(opts) do args[i] = quote(quote(opt)) end
    local script = string.format("FZFMENU_SIZE=%s fzfmenu %s < %s > %s",
        _M.picker_size, table.concat(args, " "), quote(input), quote(output))
    -- setsid makes the picker (sh, fzfmenu, st) a process group of its own,
    -- whose id is the one spawn returns, so close_picker ends all of it
    local pid
    pid = luakit.spawn("setsid sh -c " .. quote(script), function (_, status)
        if pickers[w] == pid then pickers[w] = nil end
        local out = {}
        fh = io.open(output, "r")
        if fh then
            for line in fh:lines() do out[#out + 1] = line end
            fh:close()
        end
        os.remove(input)
        os.remove(output)
        if not w.win then return end
        if status == 127 then return w:error("No fzfmenu in PATH (the dotfiles' bin/)") end
        done(out)
    end)
    pickers[w] = pid
end

-- the length of s in characters, not bytes
local function chars(s) return select(2, s:gsub("[^\128-\191]", "")) end

local function pick_links(w, query)
    local width, files = 0, {}
    for i, path in ipairs(_M.files()) do
        files[i] = { rel = relative(path), entries = entries_of(read(path)) }
        width = math.max(width, chars(files[i].rel))
    end
    width = math.min(width, 60)
    -- what fzf shows and searches, the file's path, the title and the URI,
    -- then, hidden, the path and the URI again, to act on
    local lines = {}
    for _, f in ipairs(files) do
        local pad = string.rep(" ", width - chars(f.rel))
        for _, e in ipairs(f.entries) do
            lines[#lines + 1] = string.format("\27[36m%s\27[0m%s  %s\27[90m%s\27[0m\t%s\t%s",
                f.rel, pad, e.title and e.title .. "  " or "", e.uri, f.rel, e.uri)
        end
    end
    if #lines == 0 then return w:error("No tab files in " .. short(_M.dir)) end
    pick(w, lines, {
        "--reverse", "--multi", "--print-query", "--expect=ctrl-t,ctrl-w,ctrl-o,ctrl-x",
        "--ansi", "--delimiter=\t", "--with-nth=1", "--prompt=tab files> ", "--query=" .. (query or ""),
        "--header=enter: here  ^t: new tabs  ^w: new window  ^o: whole file  ^x: remove  tab: select",
    }, function (out)
        -- the query, the key that ended it (empty for enter), the links
        local key, links = out[2], {}
        for i = 3, #out do
            local rel, uri = out[i]:match("\t([^\t]*)\t([^\t]*)$")
            if uri then links[#links + 1] = { path = resolve(rel), uri = uri } end
        end
        if #links == 0 then return end
        if key == "" then
            w:navigate(links[1].uri)
            for i = 2, #links do w:new_tab(links[i].uri, { switch = false }) end
        elseif key == "ctrl-t" then
            for i, l in ipairs(links) do w:new_tab(l.uri, { switch = i == 1 }) end
        elseif key == "ctrl-w" then
            local nw = window.new({ links[1].uri })
            for i = 2, #links do nw:new_tab(links[i].uri, { switch = false }) end
        elseif key == "ctrl-o" then
            edit(w, { arg = links[1].path })
        elseif key == "ctrl-x" then
            local err
            for _, l in ipairs(links) do err = remove_link(l.path, l.uri) or err end
            if err then w:error(err) end
            pick_links(w, out[1])
        end
    end)
end

local function add(w, o)
    local uri = w.view.uri
    if is_blank(uri) then return w:error("No page in this tab") end
    local title = clean_title(w.view.title, uri)
    if o.arg then return add_to(w, uri, title, o.arg) end
    local rels = {}
    for _, path in ipairs(_M.files()) do rels[#rels + 1] = relative(path) end
    pick(w, rels, {
        "--reverse", "--print-query", "--prompt=add to> ",
        "--header=enter: add to the file  (a name that matches none makes a new file)",
    }, function (out)
        -- the query, then the file picked, if one matched
        local name = out[2] or out[1]
        if name and name ~= "" then add_to(w, uri, title, name) end
    end)
end

-- Completion. Only luakit builds with completion.completers can add a group
-- (IcaroPablo/luakit, branch completion-groups).

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
end

modes.add_cmds({
    { ":te[dit]", "Open a tab file in a window bound to it, or reread the bound one.",
        { func = edit, format = format } },
    { ":tw[rite]", "Write the window's tabs to its tab file, or to a new one.",
        { func = write, format = format } },
    { ":tadd", "Add the current page to a tab file, picked with fzf if not given.",
        { func = add, format = format } },
    { ":tabfiles", "Pick links from every tab file with fzf, to open or remove.",
        function (w, o) pick_links(w, o.arg) end },
})

-- gb in place of luakit's bookmarks manager, which gB still opens
modes.add_binds("normal", {
    { "^gb$", "Pick links from every tab file with fzf, as `:tabfiles`.",
        function (w) pick_links(w) end },
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
    w:add_signal("close", function ()
        bound[w] = nil
        close_picker(w)
    end)
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
            local text = read(ws.tabfile)
            bound[w] = { path = ws.tabfile, saved = text_of(uris_of(text)), titles = titles_of(text) }
            w:update_win_title()
        end
    end
end)

return _M

-- vim: et:sw=4:ts=8:sts=4
