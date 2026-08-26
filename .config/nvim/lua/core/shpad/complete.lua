-- Exporta só a tabela da fonte; quem registra é o plugins/nvim-cmp.lua.
local M = {}

local KIND = vim.lsp.protocol.CompletionItemKind

-- Os que não existem como arquivo em lugar nenhum; `cd` e `echo` estão em /bin.
local BUILTINS = {
    "alias",
    "bg",
    "break",
    "continue",
    "eval",
    "exec",
    "exit",
    "export",
    "fg",
    "getopts",
    "hash",
    "jobs",
    "local",
    "read",
    "readonly",
    "return",
    "set",
    "shift",
    "source",
    "times",
    "trap",
    "unalias",
    "unset",
    "wait",
}

local path_cache
local have_carapace

-- Sem stat() por arquivo: milhares deles para tirar meia dúzia de nomes.
local function commands()
    if path_cache then
        return path_cache
    end

    local seen, out = {}, {}
    for _, name in ipairs(BUILTINS) do
        seen[name] = true
        out[#out + 1] = { label = name, kind = KIND.Keyword, detail = "builtin" }
    end

    for dir in (vim.env.PATH or ""):gmatch("[^:]+") do
        local fs = vim.uv.fs_scandir(dir)
        while fs do
            local name = vim.uv.fs_scandir_next(fs)
            if not name then
                break
            end
            if not seen[name] then
                seen[name] = true
                out[#out + 1] = { label = name, kind = KIND.Function, detail = dir }
            end
        end
    end

    path_cache = out
    return out
end

-- Sem aspas nem expansão; espaço no fim é uma palavra nova, vazia.
local function words(line)
    local out = {}
    for w in line:gmatch("%S+") do
        out[#out + 1] = w
    end
    if line == "" or line:match("%s$") then
        out[#out + 1] = ""
    end
    return out
end

-- description e tag são opcionais: um alvo de Makefile volta só com value.
-- `messages` diz por que não houve candidato; não é um deles.
local function parse(stdout)
    local ok, data = pcall(vim.json.decode, stdout or "")
    if not ok or type(data) ~= "table" or type(data.values) ~= "table" then
        return {}
    end

    local items = {}
    for _, v in ipairs(data.values) do
        if type(v) == "table" and v.value and v.value ~= "" then
            items[#items + 1] = {
                label = v.value,
                documentation = v.description ~= "" and v.description or nil,
                detail = v.tag ~= "" and v.tag or nil,
            }
        end
    end
    return items
end

local source = {}

function source.new()
    return setmetatable({}, { __index = source })
end

-- O padrão do cmp pararia no hífen e na barra, partindo `--repo` em dois.
function source:get_keyword_pattern()
    return [[\S\+]]
end

function source:get_trigger_characters()
    return { "-", "/" }
end

function source:complete(params, callback)
    -- A anterior perdeu a validade quando a linha mudou.
    if self.job then
        pcall(function()
            self.job:kill(9)
        end)
        self.job = nil
    end

    local w = words(params.context.cursor_before_line or "")
    if #w <= 1 then
        return callback(commands())
    end

    if have_carapace == nil then
        have_carapace = vim.fn.executable("carapace") == 1
    end
    if not have_carapace or vim.fn.executable(w[1]) ~= 1 then
        return callback(nil)
    end

    -- Sem allowlist porque o carapace devolve vazio para o que não conhece, sem
    -- nunca executar o que você digitou. Sondar `<cmd> __complete` executava.
    local argv = { "carapace", w[1], "export", w[1] }
    for i = 2, #w do
        argv[#argv + 1] = w[i]
    end

    local opts = { text = true, cwd = require("core.shpad").cwd() }
    self.job = vim.system(argv, opts, function(res)
        self.job = nil
        local items = res.code == 0 and parse(res.stdout) or {}
        vim.schedule(function()
            callback(#items > 0 and items or nil)
        end)
    end)
end

M.source = source
return M
