-- Browses DLNA (UPnP AV) media servers on the local network and plays from
-- them. B opens the browser (script-binding dlna/browse); it also opens by
-- itself while mpv sits idle (mpv --player-operation-mode=pseudo-gui, or
-- --idle --force-window), unless script-opts/dlna.conf says auto_open=no.
-- Picking a file queues its whole folder, so > and < move through it, and a
-- subtitle the server offers with a file is loaded with it. dlna.py, next to
-- this file, does the talking; it needs python3.

local input = require "mp.input"
local msg = require "mp.msg"
local options = require "mp.options"
local utils = require "mp.utils"

local opts = {
    auto_open = true,
    -- seconds to wait for servers to answer the search
    timeout = 1.5,
}
options.read_options(opts, "dlna")

local helper = mp.get_script_directory() .. "/dlna.py"
local servers -- those that answered the last search
local server_pick = 1
local stack = {} -- the open folders, outermost first
local busy = false
local show

local function fail(err)
    busy = false
    msg.error(err)
    mp.osd_message("DLNA: " .. err, 5)
end

local function run(args, done, failed)
    local function fail_with(err)
        fail(err)
        if failed then failed() end
    end
    busy = true
    local cmd = {"python3", "-I", helper}
    for _, a in ipairs(args) do cmd[#cmd + 1] = a end
    mp.command_native_async({
        name = "subprocess", args = cmd, capture_stdout = true,
        capture_stderr = true, playback_only = false,
    }, function(ok, r, err)
        if not ok then return fail_with(err or "couldn't run dlna.py") end
        if r.error_string == "init" then return fail_with("couldn't start python3") end
        if r.status ~= 0 then
            return fail_with(r.stderr:match("([^\n]+)%s*$") or "dlna.py failed")
        end
        local data = utils.parse_json(r.stdout)
        if type(data) ~= "table" then return fail_with("dlna.py's answer isn't JSON") end
        busy = false
        mp.osd_message("", 0)
        done(data)
    end)
end

local function open(server, id, title)
    mp.osd_message("DLNA: opening " .. title .. "…", 30)
    run({"browse", server.control, server.service, id}, function(items)
        stack[#stack + 1] = {server = server, title = title, items = items, pick = 1}
        show()
    end, function()
        -- a server gone from where it was: search again next time
        if id == "0" then servers = nil end
    end)
end

local function play(level, k)
    local files, at = {}, 1
    for i, e in ipairs(level.items) do
        if not e.dir then
            files[#files + 1] = e
            if i == k then at = #files end
        end
    end
    local function load(e, flags, index)
        local o = {["force-media-title"] = e.title}
        if e.sub ~= nil then o["sub-file"] = e.sub end
        mp.command_native({name = "loadfile", url = e.url, flags = flags,
            index = index, options = o})
    end
    load(files[at], "replace")
    for j = 1, at - 1 do load(files[j], "insert-at", j - 1) end
    for j = at + 1, #files do load(files[j], "append") end
end

-- input.select, acting on the pick once the console has closed: a menu opened
-- from submit itself gets no events, as mp.input drops its handler on the old
-- menu's "closed", which comes after submit
local function menu(t)
    local pick, submit = nil, t.submit
    t.submit = function(i) pick = i end
    t.closed = function()
        if pick then mp.add_timeout(0, function() submit(pick) end) end
    end
    input.select(t)
end

show = function()
    local level = stack[#stack]
    if not level then
        local names = {}
        for i, s in ipairs(servers) do names[i] = s.name end
        menu({
            prompt = "DLNA server:", items = names, default_item = server_pick,
            submit = function(i)
                server_pick = i
                open(servers[i], "0", servers[i].name)
            end,
        })
        return
    end
    local labels, path = {"../"}, {}
    for i, e in ipairs(level.items) do
        labels[i + 1] = e.dir and e.title .. "/" or e.title
    end
    for i, l in ipairs(stack) do path[i] = l.title end
    menu({
        prompt = table.concat(path, " / ") .. ":",
        items = labels,
        default_item = math.min(level.pick + 1, #labels),
        submit = function(i)
            if i == 1 then
                table.remove(stack)
                return show()
            end
            level.pick = i - 1
            local e = level.items[i - 1]
            if e.dir then open(level.server, e.id, e.title) else play(level, i - 1) end
        end,
    })
end

local function browse()
    if busy then return end
    if #stack > 0 then return show() end
    if servers then
        if #servers > 1 then return show() end
        return open(servers[1], "0", servers[1].name)
    end
    mp.osd_message("DLNA: looking for media servers…", 30)
    run({"discover", tostring(opts.timeout)}, function(found)
        if #found == 0 then return fail("no media server answered") end
        servers = found
        browse()
    end)
end

-- so the browser reopens on what's playing now, after > or <
mp.register_event("file-loaded", function()
    local level, path = stack[#stack], mp.get_property("path")
    if not level then return end
    for i, e in ipairs(level.items) do
        if e.url == path then level.pick = i end
    end
end)

mp.observe_property("idle-active", "bool", function(_, idle)
    if idle and opts.auto_open then browse() end
end)

mp.add_key_binding("B", "browse", browse)
