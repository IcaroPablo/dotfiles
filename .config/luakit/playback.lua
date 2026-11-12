--- Speed and volume of the page's video and audio, and mpv for videos.
--
--   sk sj ss   faster, slower, normal speed     :speed [rate]
--   vk vj vv   louder, quieter, mute or unmute  :volume [percent]
--   V          play the current page in mpv     :mpv [uri]
--   ;v         play a hinted link in mpv
--
-- Speed and volume reach the media elements of the page itself, not those of
-- a player embedded from another site.

local modes = require("modes")

local _M = {}

-- set, add to or toggle a property of every <video> and <audio>; returns the
-- new value, or null when the page has none
local media_js = [=[
(function (prop, op, value) {
    var media = Array.prototype.slice.call(document.querySelectorAll("video, audio"));
    if (!media.length) return null;
    var v = media[0][prop];
    if (op == "set") v = value;
    else if (op == "add") v = Math.round((v + value) * 100) / 100;
    else if (op == "toggle") v = !v;
    if (prop == "volume") v = Math.min(1, Math.max(0, v));
    if (prop == "playbackRate") v = Math.min(16, Math.max(0.25, v));
    media.forEach(function (m) {
        // WebKit's GStreamer backend keeps the value set before the last one
        // until it's set again, so it's set twice
        m[prop] = v;
        m[prop] = v;
        if (prop == "volume" && v > 0) m.muted = false;
    });
    return String(v);
})(%q, %q, %s)
]=]

local function media(w, prop, op, value, show)
    local js = string.format(media_js, prop, op, tostring(value or 0))
    w.view:eval_js(js, { callback = function (ret, err)
        if not w.win then return end
        if err then return w:error(err) end
        if not ret then return w:error("No video or audio on this page") end
        w:notify(show(ret))
    end })
end

local function speed(w, op, value)
    media(w, "playbackRate", op, value, function (v) return "Speed " .. v .. "x" end)
end

local function volume(w, op, value)
    media(w, "volume", op, value, function (v)
        return string.format("Volume %d%%", math.floor(tonumber(v) * 100 + 0.5))
    end)
end

local function mute(w)
    media(w, "muted", "toggle", nil, function (v) return v == "true" and "Muted" or "Unmuted" end)
end

local function quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function mpv(w, uri)
    if not uri or uri == "" then return w:error("Nothing to play") end
    w:notify("Playing in mpv: " .. uri)
    luakit.spawn("mpv --force-window=immediate -- " .. quote(uri), function (_, status)
        -- 1: couldn't start, 2: couldn't play; the rest is how it was quit
        if (status == 1 or status == 2) and w.win then
            w:error("mpv couldn't play " .. uri)
        end
    end)
end

modes.add_binds("normal", {
    { "sk", "Play the page's video and audio faster.", function (w) speed(w, "add", 0.25) end },
    { "sj", "Play the page's video and audio slower.", function (w) speed(w, "add", -0.25) end },
    { "ss", "Play the page's video and audio at normal speed.", function (w) speed(w, "set", 1) end },
    { "vk", "Turn the page's video and audio up.", function (w) volume(w, "add", 0.1) end },
    { "vj", "Turn the page's video and audio down.", function (w) volume(w, "add", -0.1) end },
    { "vv", "Mute or unmute the page's video and audio.", mute },
    { "V", "Play the current page in mpv.", function (w) mpv(w, w.view.uri) end },
})

modes.add_binds("ex-follow", {
    { "v", "Hint links and play the chosen one in mpv.", function (w)
        w:set_mode("follow", { prompt = "mpv", selector = "uri", evaluator = "uri",
            func = function (uri) mpv(w, uri) end })
    end },
})

modes.add_cmds({
    { ":speed", "Show or set the speed of the page's video and audio (1 is normal).", function (w, o)
        local rate = tonumber(o.arg)
        if o.arg and not rate then return w:error("Usage: :speed [rate], like :speed 1.5") end
        speed(w, rate and "set" or "get", rate)
    end },
    { ":volume", "Show or set the volume of the page's video and audio, in percent.", function (w, o)
        local percent = tonumber(o.arg)
        if o.arg and not percent then return w:error("Usage: :volume [percent], like :volume 30") end
        volume(w, percent and "set" or "get", percent and percent / 100)
    end },
    { ":mpv", "Play the current page, or the given URI, in mpv.", function (w, o)
        mpv(w, o.arg or w.view.uri)
    end },
})

return _M

-- vim: et:sw=4:ts=8:sts=4
