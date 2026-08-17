-- Ponto único de criação de mapeamentos, e o checador de choque que ele
-- viabiliza. `noremap` fica fora dos defaults porque vim.keymap.set ignora essa
-- opção — já é non-remapping por padrão.

local M = {}

local MODES = { "n", "x", "s", "o", "i", "c", "t" }

-- Choques vistos na criação. Nunca bloqueiam nada: o mapeamento é criado e isso
-- aqui só alimenta o relatório. Indexado pra que ftplugin reexecutado no mesmo
-- buffer (um `:e`, por exemplo) não conte o mesmo choque duas vezes.
local conflicts = {}

function M.set(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("keep", opts or {}, { silent = true })

    local at = debug.getinfo(2, "Sl")
    local here = at and vim.fn.fnamemodify((at.source:gsub("^@", "")), ":p") or ""

    for _, m in ipairs(type(mode) == "table" and mode or { mode }) do
        -- sid > 0 saiu de algum script; sid < 0 é builtin do neovim, e cobrir
        -- builtin é intencional. Escopo diferente é sombreamento, não choque.
        local prev = vim.fn.maparg(lhs, m, false, true)
        if not vim.tbl_isempty(prev) and prev.sid > 0 and (prev.buffer == 1) == (opts.buffer ~= nil) then
            -- mesmo arquivo de origem significa reexecução (ftplugin num `:e`,
            -- LspAttach em outro cliente), não alguém pisando no mapeamento
            local info = vim.fn.getscriptinfo({ sid = prev.sid })[1]
            if here ~= (info and vim.fn.fnamemodify(info.name, ":p") or "") then
                local src = vim.fn.fnamemodify(here, ":~:.") .. ":" .. at.currentline
                conflicts[m .. lhs .. src] = ("choque     %s [%s]  sobrescreve %s  em %s"):format(lhs, m, prev.rhs or "<lua>", src)
            end
        end
    end

    vim.keymap.set(mode, lhs, rhs, opts)
end

--- Choques de criação, mais sombreamento e prefixo lidos da API no buffer atual.
--- Prefixo ignora builtin (`sid < 0`): `gc`/`gcc` é par do neovim, não choque. E
--- um `<Nop>` nunca é vítima — ele existe pra absorver o prefixo, que é o caso
--- do `<Space>` quando o leader é espaço.
function M.check()
    local out = vim.tbl_values(conflicts)

    for _, mode in ipairs(MODES) do
        local global, all = {}, vim.api.nvim_get_keymap(mode)
        for _, km in ipairs(all) do
            global[km.lhs] = true
        end
        for _, km in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
            if global[km.lhs] then
                out[#out + 1] = ("sombreado  %s [%s]  buffer-local vence"):format(km.lhs, mode)
            end
            all[#all + 1] = km
        end

        for _, short in ipairs(all) do
            local nop = short.rhs == "" and short.callback == nil
            if short.sid > 0 and not nop then
                local longs = {}
                for _, long in ipairs(all) do
                    if #long.lhsraw > #short.lhsraw and long.lhsraw:sub(1, #short.lhsraw) == short.lhsraw then
                        longs[#longs + 1] = long.lhs
                    end
                end
                if #longs > 0 then
                    table.sort(longs)
                    out[#out + 1] = ("prefixo    %s [%s]  espera timeoutlen por: %s"):format(short.lhs, mode, table.concat(longs, " "))
                end
            end
        end
    end

    table.sort(out)
    return out
end

--- Uma linha no startup quando há choque; o detalhe fica no :MapCheck.
function M.notify()
    local n = #M.check()
    if n > 0 then
        vim.notify(("keymaps: %d choque(s) — :MapCheck"):format(n), vim.log.levels.WARN)
    end
end

return M
