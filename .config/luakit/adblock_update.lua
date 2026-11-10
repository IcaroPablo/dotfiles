--- :adblock-update (:abu) downloads the filter lists below into luakit's
-- adblock folder and reloads the ad blocker. A list that fails to download,
-- or doesn't look like a filter list, keeps its previous copy.

local adblock = require("adblock")
local modes = require("modes")

local _M = {}

-- file name in the adblock folder -> where it comes from; luakit only reads
-- Adblock Plus lists, and of those only the rules that block requests
_M.lists = {
    ["easylist.txt"] = "https://easylist.to/easylist/easylist.txt",
    ["easyprivacy.txt"] = "https://easylist.to/easylist/easyprivacy.txt",
}

local dir = luakit.data_dir .. "/adblock/"
local running = false

local function quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function is_filter_list(path)
    local fh = io.open(path, "r")
    if not fh then return false end
    local first = fh:read("*l") or ""
    fh:close()
    return first:match("^%[Adblock") ~= nil or first:match("^!") ~= nil
end

local function report(w, text, failed)
    if not w.win then return end
    if #failed > 0 then
        w:error(text .. "; failed: " .. table.concat(failed, ", "))
    else
        w:notify(text)
    end
end

local function update(w)
    if running then return w:error("adblock: update already running") end
    local pending = 0
    for _ in pairs(_M.lists) do pending = pending + 1 end
    if pending == 0 then return w:error("adblock: no lists to update") end

    running = true
    w:notify("adblock: updating " .. pending .. " lists...")
    local failed = {}
    for name, url in pairs(_M.lists) do
        local part = dir .. name .. ".part"
        local cmd = "curl -fsSL --compressed --max-time 120 -o " .. quote(part) .. " " .. quote(url)
        luakit.spawn(cmd, function (_, status)
            if status == 0 and is_filter_list(part) then
                os.rename(part, dir .. name)
            else
                os.remove(part)
                failed[#failed + 1] = name
            end
            pending = pending - 1
            if pending > 0 then return end

            running = false
            adblock.load(true)
            local rules = 0
            for _, list in pairs(adblock.rules) do
                rules = rules + (list.black or 0) + (list.white or 0)
            end
            report(w, string.format("adblock: lists updated, %d rules loaded", rules), failed)
        end)
    end
end

modes.add_cmds({
    { ":adblock-update, :abu", "Download the adblock filter lists again and reload them.", update },
})

return _M

-- vim: et:sw=4:ts=8:sts=4
