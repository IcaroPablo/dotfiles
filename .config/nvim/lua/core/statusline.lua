-- Statusline nativa, sem plugin. Instalada como expressão em vim.o.statusline,
-- então o retorno é reinterpretado como formato de statusline e itens como %=,
-- %l:%c e %p%% continuam valendo aqui dentro.

local M = {}

local MODES = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",
    R = "REPLACE",
    c = "COMMAND",
    t = "TERMINAL",
    no = "OP-PENDING",
}

--- `%` em texto dinâmico viraria código de statusline (um arquivo "100%.txt"
--- corromperia a linha inteira).
local function escape(s)
    return (s:gsub("%%", "%%%%"))
end

--- Encurta os diretórios da frente, um por vez, até caber no orçamento.
--- Preserva os dois últimos diretórios e o nome do arquivo por inteiro.
local function fit(path, budget)
    if vim.fn.strdisplaywidth(path) <= budget then
        return path
    end
    local parts = vim.split(path, "/", { plain = true })
    for i = 2, math.max(1, #parts - 3) do
        parts[i] = parts[i]:sub(1, 1)
        local try = table.concat(parts, "/")
        if vim.fn.strdisplaywidth(try) <= budget then
            return try
        end
    end
    return table.concat(parts, "/")
end

local function filetype()
    local ft = vim.bo.filetype
    if ft == "" then
        return ""
    end
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then
        return ft
    end
    local icon = devicons.get_icon_by_filetype(ft, { default = true })
    return icon and (icon .. " " .. ft) or ft
end

function M.render()
    -- o %! é avaliado uma vez por janela: vim.fn.mode() devolveria o modo da
    -- janela ativa em todas, e a largura precisa ser a da janela, não a do
    -- terminal (com laststatus=2 cada janela tem a sua statusline)
    local win = vim.g.statusline_winid
    local active = win == vim.api.nvim_get_current_win()
    local width = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_width(win) or vim.o.columns

    local parts = {}
    if active then
        parts[#parts + 1] = MODES[vim.fn.mode()] or vim.fn.mode()
    end
    if vim.b.gitsigns_head then
        parts[#parts + 1] = vim.b.gitsigns_head
    end
    local left = table.concat(parts, "  ")

    local right = filetype()
    local tail = "  %p%%  %l:%c "

    local path = vim.fn.expand("%:p")
    if path == "" then
        path = "[sem nome]"
    end
    local used = vim.fn.strdisplaywidth(left .. right .. tail) + 8
    path = fit(path, math.max(20, width - used))

    return " " .. escape(left) .. (left == "" and "" or "  ") .. escape(path) .. "%m%=" .. escape(right) .. tail
end

return M
