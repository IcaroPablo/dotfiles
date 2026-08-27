local M = {}

-- No `\21` prefix to clear a half-typed line: readline bells on an empty-line
-- kill, and an empty prompt is the normal state. Measured, it beeped per command.

-- Fifo com leitor não bloqueia na abertura, e é o que o broker e o dvtm garantem
-- enquanto vivos. Sem leitor isto penduraria o editor, daí a checagem em `pane`.
local function write_line(path, text)
    local fh = io.open(path, "a")
    if not fh then
        return false
    end
    fh:write(text .. "\n")
    fh:close()

    return true
end

-- EPERM é vivo e de outro dono; só ESRCH é ausência.
local function dead(pid)
    local _, err = vim.uv.kill(pid, 0)
    return err ~= nil and tostring(err):match("^ESRCH") ~= nil
end

-- Painel de pé é broker vivo mais o fifo dele. Vivo porque fifo sem leitor trava
-- quem abre pra escrever; fifo porque escrever num caminho que não existe criaria
-- ali um arquivo comum, que o broker então lê no lugar do fifo.
local function pane()
    local path, pid = vim.env.SHPAD_FIFO, tonumber(vim.env.SHPAD_PID)
    if not path or not pid or dead(pid) then
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

-- Estacionar em vez de fechar: o nvim segue vivo, com modo de inserção, cursor e
-- undo no lugar. A volta são duas linhas porque o `focus` do dvtm torna visível e
-- foca, mas SOMA a tag à vista sem largar a do estacionamento (`c->tags |=
-- tagset[seltags]`, em focusid) -- sem a segunda o mesmo painel segue desenhado
-- na 9, o que de fora é igual a um command buffer duplicado.
--
-- Vai em arquivo porque quem manda a volta é o broker, e o id do painel não
-- existia quando ele começou.
local function park()
    local win, file = vim.env.DVTM_WINDOW_ID, vim.env.SHPAD_ON_IDLE_FILE
    local dvtm = vim.env.DVTM_CMD_FIFO
    if not win or not file or not dvtm then
        return false
    end

    local tag = vim.env.SHPAD_PARK_TAG or "9"
    local back = { "focus " .. win, ("tag %s -%s"):format(win, tag) }

    return vim.fn.writefile(back, file) == 0 and write_line(dvtm, ("tag %s %s"):format(win, tag))
end

local function send(text)
    if not text or text:match("^%s*$") then
        return
    end

    local why = parse_error(text)
    if why then
        return vim.notify("shpad: " .. why, vim.log.levels.ERROR)
    end

    local path = pane()
    if not path then
        return vim.notify("shpad: o painel não está de pé", vim.log.levels.WARN)
    end

    -- Sai de cena antes de mandar: o comando ocupa o painel inteiro, e coisa
    -- interativa fica utilizável. Antes porque o broker dispara a volta 260 ms
    -- depois de receber, e um nvim lento nesse meio veria a volta chegar antes de
    -- ter saído.
    vim.cmd("silent! wall")
    if not park() then
        vim.notify("shpad: não consegui sair de cena", vim.log.levels.WARN)
    end

    write_line(path, text)
end

function M.run()
    send(selection())
end

function M.run_paragraph()
    send(paragraph())
end

-- O command buffer não sobrevive ao broker: sem isto ele fica em cena como um
-- editor morto, indistinguível do vivo, e você só descobre ao mandar um comando.
-- Olha o pid e não o fifo -- broker morto à força não chega a apagar o dele.
function M.watch()
    local pid = tonumber(vim.env.SHPAD_PID)
    if not pid then
        return
    end

    local timer = vim.uv.new_timer()
    timer:start(2000, 2000, function()
        if not dead(pid) then
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
    local pid = vim.env.SHPAD_PID

    if pid and pid ~= "" and not cwd_pending then
        cwd_pending = true
        local find = 'p=$(pgrep -P "$1" | head -1) && [ -n "$p" ] && lsof -a -p "$p" -d cwd -Fn'
        vim.system({ "sh", "-c", find, "sh", pid }, { text = true }, function(res)
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
