-- shpad - run the paragraph under the cursor in the shell pane.
--
-- The pane is not a child of this editor. shpad-run owns a pty for the shell
-- and reads a fifo, so all this module does is put bytes in that fifo. Nothing
-- here waits for a result and nothing here learns whether the command
-- succeeded: the transcript in the other pane is the answer.

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
-- shpad-run then finds with EEXIST and reads as if it were the fifo. Better to
-- fall back and run detached than to leave that behind.
local function fifo()
    local path = vim.env.SHPAD_FIFO
    if not path or path == "" then
        return nil
    end
    local st = vim.uv.fs_stat(path)
    return (st and st.type == "fifo") and path or nil
end

local function selected_text()
    local first = vim.api.nvim_buf_get_mark(0, "<")[1]
    local last = vim.api.nvim_buf_get_mark(0, ">")[1]
    return table.concat(vim.api.nvim_buf_get_lines(0, first - 1, last, false), "\n")
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

-- What this did before there was a pane to send to: run in a subshell and show
-- the output in a scratch buffer. Kept so the mapping still does something
-- sensible in an nvim that was not started by shpad.
local function run_detached(text)
    local res = vim.system({ vim.o.shell }, { stdin = text, text = true }):wait()
    local output = vim.split((res.stdout or "") .. (res.stderr or ""), "\n")

    vim.cmd("vnew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end

function M.run()
    local text = selected_text()
    if text:match("^%s*$") then
        return
    end

    local why = parse_error(text)
    if why then
        vim.notify("shpad: " .. why, vim.log.levels.ERROR)
        return
    end

    local path = fifo()
    if not path then
        return run_detached(text)
    end

    -- Written by a child process rather than by nvim itself: opening a fifo
    -- blocks until its reader is there, so a dead pane would otherwise freeze
    -- the editor. No :wait() here for the same reason.
    vim.system({ "sh", "-c", 'cat >> "$0"', path }, { stdin = text .. "\n" })
end

return M
