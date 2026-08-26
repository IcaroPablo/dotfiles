-- shpad - run a paragraph of this buffer in the shell pane.
--
-- The pane is not a child of this editor. shpad-run owns a pty for the shell
-- and reads a fifo, so all this module does is put bytes in that fifo. Nothing
-- here waits for a result and nothing here learns whether the command
-- succeeded: the transcript in the other pane is the answer.
--
-- Two ways in. <leader>R takes a visual selection or `vip`, from normal mode.
-- <C-CR> takes the paragraph under the cursor and is meant for insert mode --
-- mapped through <Cmd>, so it neither leaves insert nor moves the cursor.
--
-- Without a pane there is nothing to do but say so. Running the text in a
-- throwaway subshell was the old behaviour and it lied about what shpad is:
-- state did not persist, and nothing prompted could be answered.

local M = {}

-- Nothing is sent to clear a half-typed line at the prompt, and that is on
-- purpose. `\21` looked right -- termios VKILL in canonical mode,
-- unix-line-discard under readline -- but readline rings the bell when asked to
-- kill an empty line, and an empty prompt is the normal state. Measured: with
-- the prefix, every single command beeps; without it, silence. Paying a bell per
-- command to guard against text you left sitting in the other pane, which is
-- rare and plainly visible when it happens, is the wrong trade.

-- The type is checked, not merely the existence. If the pane has not created
-- the fifo yet, appending to that path would make a regular FILE there, which
-- shpad-run then finds with EEXIST and reads as if it were the fifo.
local function fifo()
    local path = vim.env.SHPAD_FIFO
    if not path or path == "" then
        return nil
    end
    local st = vim.uv.fs_stat(path)
    return (st and st.type == "fifo") and path or nil
end

-- `sh -n` parses without executing. Without it an unbalanced quote reaches the
-- pane, the shell settles at a PS2 prompt, and every later paragraph piles onto
-- the broken line rather than running.
local function parse_error(text)
    local res = vim.system({ "sh", "-n" }, { stdin = text, text = true }):wait()
    if res.code == 0 then
        return nil
    end
    local why = (res.stderr or ""):gsub("%s+$", "")
    return why ~= "" and why or "syntax error"
end

-- Written by a child process rather than by nvim itself: opening a fifo blocks
-- until its reader is there, so a dead pane would otherwise freeze the editor.
-- No :wait() for the same reason.
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

-- The paragraph around the cursor, found by scanning out to blank lines. The
-- marks `'<`/`'>` do not exist in insert mode, so the visual path cannot serve
-- <C-CR>. A cursor on a blank line means you are between paragraphs and nothing
-- is sent -- guessing which neighbour you meant would eventually guess wrong.
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
