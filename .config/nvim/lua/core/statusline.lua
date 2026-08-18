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

--- Largura de um trecho que JÁ contém marcações de statusline. O
--- vim.diagnostic.status() devolve grupos de destaque embutidos
--- (`%#DiagnosticSignError#E:1 …`), que ocupam zero coluna na tela mas contam
--- no strdisplaywidth — medir cru roubaria dezenas de colunas do path.
local function largura(s)
    local ok, res = pcall(vim.api.nvim_eval_statusline, s, { winid = vim.g.statusline_winid })
    return ok and res.width or vim.fn.strdisplaywidth(s)
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
    local valida = vim.api.nvim_win_is_valid(win)
    local width = valida and vim.api.nvim_win_get_width(win) or vim.o.columns
    local buf = valida and vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()

    local parts = {}
    if active then
        parts[#parts + 1] = MODES[vim.fn.mode()] or vim.fn.mode()
    end
    if vim.b.gitsigns_head then
        parts[#parts + 1] = vim.b.gitsigns_head
    end
    local left = table.concat(parts, "  ")

    -- progresso só na janela ativa, como faz a statusline default do 0.12:
    -- a mensagem é global e apareceria repetida em cada split
    local segmentos = {}
    if active then
        local progresso = vim.ui.progress_status()
        if progresso ~= "" then
            segmentos[#segmentos + 1] = progresso
        end
    end
    -- next() antes de status(): sem diagnóstico a função devolveria "" e o
    -- separador ficaria sobrando
    if next(vim.diagnostic.count(buf)) then
        segmentos[#segmentos + 1] = vim.diagnostic.status(buf)
    end
    local ft = filetype()
    if ft ~= "" then
        segmentos[#segmentos + 1] = ft
    end

    local right = table.concat(segmentos, "  ")
    local tail = "  %p%%  %l:%c "

    local path = vim.fn.expand("%:p")
    if path == "" then
        path = "[sem nome]"
    end
    -- right não passa pelo escape: diagnostic.status() e progress_status() já
    -- vêm com marcações de statusline, e dobrar os % as destruiria
    -- left é texto puro; right e tail carregam marcações, então vão por largura()
    local used = vim.fn.strdisplaywidth(left) + largura(right) + largura(tail) + 8
    path = fit(path, math.max(20, width - used))

    -- %< marca onde o vim corta se ainda não couber: o fit() tem piso (preserva
    -- os dois últimos diretórios), então em janela estreita sobra excesso. Sem
    -- isso o corte cai em lugar arbitrário e come o lado direito.
    return " " .. escape(left) .. (left == "" and "" or "  ") .. "%<" .. escape(path) .. "%m %=" .. right .. tail
end

return M
