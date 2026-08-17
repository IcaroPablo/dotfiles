-- `noremap` não entra nos defaults: o vim.keymap.set ignora essa opção e já é
-- non-remapping por padrão.

local M = {}

local MODES = { "n", "x", "s", "o", "i", "c", "t" }

--- Linha de base do que a config já sobrescrevia quando o checador entrou, pra
--- que só sobrescrita nova apareça. Tirar uma entrada volta a acusar a tecla.
M.allow = {
    ["<c-l>"] = "resize de janela no lugar do <C-L> nativo; o nohlsearch está no <c-[>",

    -- o ftplugin roda de novo a cada FileType (`:e`, `:set ft=java`)
    ["<leader>jtc"] = "ftplugin/java.lua",
    ["<leader>jtm"] = "ftplugin/java.lua",
    ["<leader>jdi"] = "ftplugin/java.lua",
    ["<leader>jev"] = "ftplugin/java.lua",
    ["<leader>jec"] = "ftplugin/java.lua",
    ["<leader>jem"] = "ftplugin/java.lua",
    ["<C-k>"] = "ftplugin/java.lua vs init.lua — vale revisar",
    ["<leader>rn"] = "ftplugin/java.lua vs nvim_lsp_config.lua — vale revisar",

    -- o LspAttach dispara por (cliente, buffer), então reexecuta num `:e!`
    ["<Leader>e"] = "nvim_lsp_config.lua",
    ["<Leader>ca"] = "nvim_lsp_config.lua",
    ["<Leader>cf"] = "nvim_lsp_config.lua",
    ["<Leader>rn"] = "nvim_lsp_config.lua",
    ["K"] = "nvim_lsp_config.lua",
    ["gD"] = "nvim_lsp_config.lua",
    ["gd"] = "nvim_lsp_config.lua",
    ["gi"] = "nvim_lsp_config.lua",
    ["gr"] = "nvim_lsp_config.lua",
    ["gt"] = "nvim_lsp_config.lua",
    ["[d"] = "nvim_lsp_config.lua — cobre builtin que faz o mesmo",
    ["]d"] = "nvim_lsp_config.lua — cobre builtin que faz o mesmo",

    -- o on_attach do gitsigns roda por buffer, e de novo num reload
    ["<leader>hr"] = "gitsigns.lua",
    ["<leader>hR"] = "gitsigns.lua",
    ["<leader>hp"] = "gitsigns.lua",
    ["<leader>td"] = "gitsigns.lua",
    ["[c"] = "gitsigns.lua",
    ["]c"] = "gitsigns.lua",
    ["ih"] = "gitsigns.lua",
}

local conflicts = {}

function M.set(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("keep", opts or {}, { silent = true })

    local at = debug.getinfo(2, "Sl")
    local here = at and vim.fn.fnamemodify((at.source:gsub("^@", "")), ":p") or ""

    for _, m in ipairs(type(mode) == "table" and mode or { mode }) do
        local prev = vim.fn.maparg(lhs, m, false, true)
        if not vim.tbl_isempty(prev) and not M.allow[lhs] then
            local src = vim.fn.fnamemodify(here, ":~:.") .. ":" .. at.currentline
            local name = m == "" and "nvo" or m
            local lost = prev.sid < 0 and "um builtin do neovim" or (prev.rhs or "<lua>")
            conflicts[m .. lhs .. src] = ("choque   %s [%s]  sobrescreve %s  em %s"):format(lhs, name, lost, src)
        end
    end

    vim.keymap.set(mode, lhs, rhs, opts)
end

--- Uma tecla que é começo de outra só dispara depois do 'timeoutlen'. Builtin
--- fica fora, senão o par `gc`/`gcc` do neovim viraria achado; e um `<Nop>` nunca
--- é vítima, porque existe justamente pra absorver o prefixo (é o `<Space>`
--- quando o leader é espaço).
function M.check()
    local out = vim.tbl_values(conflicts)

    for _, mode in ipairs(MODES) do
        local all = vim.api.nvim_get_keymap(mode)
        vim.list_extend(all, vim.api.nvim_buf_get_keymap(0, mode))

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
                    out[#out + 1] = ("prefixo  %s [%s]  espera timeoutlen por: %s"):format(short.lhs, mode, table.concat(longs, " "))
                end
            end
        end
    end

    table.sort(out)
    return out
end

function M.notify()
    local n = #M.check()
    if n > 0 then
        vim.notify(("keymaps: %d choque(s) — :MapCheck"):format(n), vim.log.levels.WARN)
    end
end

return M
