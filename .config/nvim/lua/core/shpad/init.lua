local M = {}

-- No `\21` prefix to clear a half-typed line: readline bells on an empty-line
-- kill, and an empty prompt is the normal state. Measured, it beeped per command.

local me = vim.env.DVTM_WINDOW_ID
local dvtm = vim.env.DVTM_CMD_FIFO
local shell_win = vim.env.SHPAD_SHELL_WIN
local shell_pid = tonumber(vim.env.SHPAD_SHELL_PID)
local send_file = shell_win and vim.fn.tempname()

-- EPERM é vivo e de outro dono; só ESRCH é ausência.
local function dead(pid)
    local _, err = vim.uv.kill(pid, 0)
    return err ~= nil and tostring(err):match("^ESRCH") ~= nil
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

-- Três linhas numa escrita só, na ordem em que o dvtm as executa: sair de cena,
-- pedir a volta e mandar o comando. `minimize` porque o `focus` já desminimiza, e
-- `onidle` porque quem enxerga o terminal do outro painel é o dvtm, não o editor.
--
-- O texto vai por arquivo porque o canal do dvtm termina o comando na primeira
-- quebra de linha, e um comando com o Enter dentro tem no mínimo duas. Abrir esse
-- canal para escrever não pendura ninguém: quem lê é o dvtm, e se ele morrer este
-- editor morreu junto.
local function run(text)
    if vim.fn.writefile(vim.split(text, "\n"), send_file) ~= 0 then
        return false
    end

    local fh = io.open(dvtm, "a")
    if not fh then
        return false
    end
    local cmd = "minimize %s\nonidle %s focus %s\nsend %s %s\n"
    fh:write(cmd:format(me, shell_win, me, shell_win, send_file))
    fh:close()

    return true
end

local function send(text)
    if not text or text:match("^%s*$") then
        return
    end

    local why = parse_error(text)
    if why then
        return vim.notify("shpad: " .. why, vim.log.levels.ERROR)
    end

    if dead(shell_pid) then
        return vim.notify("shpad: o painel não está de pé", vim.log.levels.WARN)
    end

    vim.cmd("silent! wall")
    if not run(text) then
        vim.notify("shpad: não consegui mandar o comando", vim.log.levels.ERROR)
    end
end

function M.run()
    send(selection())
end

function M.run_paragraph()
    send(paragraph())
end

-- O command buffer não sobrevive ao painel para onde ele manda: sem isto ele fica
-- em cena como um editor sem destino, indistinguível de um bom, e você só descobre
-- ao mandar um comando.
function M.watch()
    local timer = vim.uv.new_timer()
    timer:start(2000, 2000, function()
        if not dead(shell_pid) then
            return
        end

        timer:stop()
        vim.schedule(function()
            vim.cmd("silent! wall")
            vim.cmd("qa!")
        end)
    end)
end

local cwd_cache, cwd_pending

-- O cwd do shell do painel, não o do nvim: é contra ele que o carapace resolve
-- branch de git e alvo de Makefile. lsof, e não /proc, porque é um caminho só --
-- o OpenBSD traz fstat no base e precisaria de pkg_add lsof.
--
-- Volta do cache e atualiza em segundo plano: fica no máximo uma tecla atrasado
-- depois de um cd, e nunca bloqueia o editor.
function M.cwd()
    if shell_pid and not cwd_pending then
        cwd_pending = true
        local argv = { "lsof", "-a", "-p", tostring(shell_pid), "-d", "cwd", "-Fn" }
        vim.system(argv, { text = true }, function(res)
            cwd_pending = false
            for line in (res.stdout or ""):gmatch("[^\n]+") do
                if line:sub(1, 2) == "n/" then
                    cwd_cache = line:sub(2)
                end
            end
        end)
    end

    return cwd_cache or vim.fn.getcwd()
end

return M
