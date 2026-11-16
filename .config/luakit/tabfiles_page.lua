--- luakit://tabfiles/: every tab file (see tabfiles.lua) and its links, by
-- directory, with a filter.
--
--   :tabfiles [words]      open the page, filtered by words
--
-- A file's links fold under its name; the filter unfolds the files that
-- match, showing every link of a file whose path matches and only the
-- matching links of the others. Links open as any other: f, F, a click. A
-- file's "open" button opens all its tabs, as :te does, and a link's ✕ takes
-- it out of its file, unless the file is open in a window, where its tabs
-- are the ones to change.

local window = require("window")
local modes = require("modes")
local chrome = require("chrome")
local history = require("history")
local tabfiles = require("tabfiles")

local _M = {}

local html = [==[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Tab files</title>
<style>
{stylesheet}
#page-header { gap: 1.5em; }
#page-header #filter { width: 26em; border-radius: 0.25rem; }
#stats { color: #777; font-size: 0.85rem; }
#list { padding-bottom: 3em; }
h2 { font-size: 0.95rem; color: #556; margin: 1.4em 0 0.3em; }
details { margin: 0; }
summary {
    display: flex; align-items: baseline; gap: 0.8em; list-style: none;
    padding: 0.2em 0.4em; border-radius: 0.25rem; cursor: pointer;
}
summary::-webkit-details-marker { display: none; }
summary::before { content: "▸"; color: #999; width: 0.8em; }
details[open] > summary::before { content: "▾"; }
summary:hover { background: #f0f0f0; }
.name { font-weight: 600; }
.count, .note { color: #888; font-size: 0.85em; }
button {
    font: inherit; font-size: 0.75em; padding: 0.1em 0.6em; cursor: pointer;
    border: 1px solid #ccc; border-radius: 0.25rem; background: #f7f7f7; color: #444;
}
ul { list-style: none; margin: 0.1em 0 0.5em 1.6em; padding: 0; }
li { display: flex; align-items: baseline; gap: 0.6em; padding: 0.1em 0; }
li a { color: #2a5db0; text-decoration: none; overflow-wrap: anywhere; }
li a:hover { text-decoration: underline; }
li button { border: none; background: none; color: #b55; padding: 0 0.3em; }
#error { color: #b33; }
@media (prefers-color-scheme: dark) {
    body { background: #1d1f21; color: #ddd; }
    #page-header { background: #26282b; border-bottom-color: #333; }
    #page-header > h1, h2 { color: #aab; }
    #page-header input { background: #333; color: #eee; }
    summary:hover { background: #2c2e31; }
    button { background: #2c2e31; border-color: #444; color: #ccc; }
    li a { color: #8ab4f8; }
    li button { background: none; color: #e88; }
}
</style>
</head>
<body>
<header id="page-header">
    <h1>Tab files</h1>
    <span id="search-box"><input type="text" id="filter" placeholder="Filter by link or path"></span>
    <span id="stats"></span>
    <span id="error"></span>
</header>
<div id="list" class="content-margin"></div>
<script>
const $list = document.getElementById('list')
const $filter = document.getElementById('filter')
const $stats = document.getElementById('stats')
const $error = document.getElementById('error')
let files = []

function el (tag, attrs, ...children) {
    const $e = document.createElement(tag)
    for (const [k, v] of Object.entries(attrs || {})) {
        if (k.startsWith('on')) $e.addEventListener(k.slice(2), v)
        else $e.setAttribute(k, v)
    }
    $e.append(...children.filter(c => c !== null))
    return $e
}

const list = t => Array.isArray(t) ? t : Object.values(t || {})
const plural = (n, one, many) => n + ' ' + (n === 1 ? one : many)

function matches (text, words) {
    text = text.toLowerCase()
    return words.every(w => text.includes(w))
}

function render () {
    const words = $filter.value.toLowerCase().split(/\s+/).filter(w => w)
    let dir = null, nfiles = 0, nlinks = 0
    $list.replaceChildren()
    for (const f of files) {
        const path = f.dir ? f.dir + '/' + f.name : f.name
        const whole = matches(path, words)
        const uris = whole ? f.uris : f.uris.filter(u => matches(u, words))
        if (uris.length === 0) continue
        if (f.dir !== dir) {
            dir = f.dir
            $list.append(el('h2', {}, dir ? dir + '/' : '~/Workspace'))
        }
        const count = uris.length < f.uris.length
            ? uris.length + ' of ' + f.uris.length : String(f.uris.length)
        const $open = el('button', { title: 'Open all its tabs, as :te', onclick: e => {
            e.preventDefault()
            tabfiles_open(f.path)
        } }, 'open')
        $list.append(el('details', words.length ? { open: '' } : {},
            el('summary', {},
                el('span', { class: 'name' }, f.name),
                el('span', { class: 'count' }, count),
                $open,
                f.bound ? el('span', { class: 'note' }, 'open in a window') : null),
            el('ul', {}, ...uris.map(u => el('li', {},
                el('a', { href: u }, u),
                f.bound ? null : el('button', { title: 'Remove from ' + f.name, onclick: () => remove(f, u) }, '✕'))))))
        nfiles++
        nlinks += uris.length
    }
    $stats.textContent = plural(nlinks, 'link', 'links') + ' in ' + plural(nfiles, 'file', 'files')
}

async function load () {
    files = list(await tabfiles_list())
    for (const f of files) f.uris = list(f.uris)
    render()
}

async function remove (f, uri) {
    const err = await tabfiles_remove(f.path, uri)
    $error.textContent = err || ''
    await load()
}

$filter.addEventListener('input', render)
$filter.value = decodeURIComponent(location.hash.slice(1))
load()
</script>
</body>
</html>
]==]

chrome.add("tabfiles", function ()
    return (html:gsub("{stylesheet}", function () return chrome.stylesheet end))
end, nil, {
    tabfiles_list = function () return tabfiles.list() end,
    tabfiles_open = function (view, path)
        local w = window.ancestor(view)
        if w then tabfiles.edit(w, path) end
    end,
    tabfiles_remove = function (_, path, uri) return tabfiles.remove(path, uri) end,
})

-- the page itself stays out of history
history.add_signal("add", function (uri)
    if uri:match("^luakit://tabfiles/") then return false end
end)

local function encode(s)
    return (s:gsub("[^%w%-_.~ ]", function (c) return string.format("%%%02X", c:byte()) end)
        :gsub(" ", "%%20"))
end

modes.add_cmds({
    { ":tabfiles", "Open <luakit://tabfiles/>, filtered by the words given.",
        function (w, o)
            w:new_tab("luakit://tabfiles/" .. (o.arg and "#" .. encode(o.arg) or ""))
        end },
})

return _M

-- vim: et:sw=4:ts=8:sts=4
