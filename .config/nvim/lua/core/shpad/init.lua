local M = {}

-- No `\21` prefix to clear a half-typed line: readline bells on an empty-line
-- kill, and an empty prompt is the normal state. Measured, it beeped per command.

-- The type, not just the existence: appending to a path the pane has not made
-- yet would leave a regular file there, which shpad-run then reads as the fifo.
local function fifo()
    local path = vim.env.SHPAD_FIFO
    if not path or path == "" then
        return nil
    end
    local st = vim.uv.fs_stat(path)
    return (st and st.type == "fifo") and path or nil
end

-- Unbalanced quotes otherwise strand the pane at PS2, and every later paragraph
-- piles onto the broken line.
local function parse_error(text)
    local res = vim.system({ "sh", "-n" }, { stdin = text, text = true }):wait()
    if res.code == 0 then
        return nil
    end
    local why = (res.stderr or ""):gsub("%s+$", "")
    return why ~= "" and why or "syntax error"
end

-- A child process, and never awaited: opening a fifo blocks until its reader is
-- there, so a dead pane would freeze the editor.
local function write_fifo(path, text)
    vim.system({ "sh", "-c", 'cat >> "$0"', path }, { stdin = text .. "\n" })
end

local function lines(first, last)
    return table.concat(vim.api.nvim_buf_get_lines(0, first - 1, last, false), "\n")
end

local function blank(n)
    local l = vim.api.nvim_buf_get_lines(0, n - 1, n, false)[1]
    return l == nil or l:match("^%s*$") ~= nil
end

-- Scanned from the cursor because `'<`/`'>` do not exist in insert mode. A blank
-- line sends nothing: guessing which neighbour was meant would guess wrong.
local function paragraph()
    local cur = vim.api.nvim_win_get_cursor(0)[1]
    if blank(cur) then
        return nil
    end

    local first, last = cur, cur
    local count = vim.api.nvim_buf_line_count(0)
    while first > 1 and not blank(first - 1) do
        first = first - 1
    end
    while last < count and not blank(last + 1) do
        last = last + 1
    end
    return lines(first, last)
end

local function selection()
    local first = vim.api.nvim_buf_get_mark(0, "<")[1]
    local last = vim.api.nvim_buf_get_mark(0, ">")[1]
    return lines(first, last)
end

local function send(text)
    if not text or text:match("^%s*$") then
        return
    end

    local why = parse_error(text)
    if why then
        return vim.notify("shpad: " .. why, vim.log.levels.ERROR)
    end

    local path = fifo()
    if not path then
        return vim.notify("shpad: nenhum pane ($SHPAD_FIFO)", vim.log.levels.WARN)
    end

    write_fifo(path, text)
end

function M.run()
    send(selection())
end

function M.run_paragraph()
    send(paragraph())
end

return M
