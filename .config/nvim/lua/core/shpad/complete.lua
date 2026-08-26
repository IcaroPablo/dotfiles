-- shpad.complete - uma fonte de completion do nvim-cmp para o buffer do shpad.
--
-- Exporta só a tabela da fonte; quem registra é o plugins/nvim-cmp.lua, para
-- que core/ não passe a depender de um plugin.
--
-- Três camadas, a primeira que responder ganha. A quarta é o cmp-path e o
-- cmp-buffer que já existiam, num grupo abaixo deste -- o cmp só desce para o
-- grupo seguinte quando o de cima não devolve nada.

local M = {}

-- Comandos que falam o protocolo do cobra (`cmd __complete <args>`), por lista
-- explícita e não por sondagem.
--
-- Sondar é inseguro de um jeito que não dá para consertar: rodar `<cmd>
-- __complete <o que você digitou>` executa o comando. Medido: `rm -f victim
-- __complete` apaga victim -- o -f é lido como opção, some o prompt do alias
-- `rm -i`, e o resto vira operando. A variante `rm __complete -f victim`
-- sobreviveu, mas só por acidente da ordem dos argumentos. Depender disso seria
-- apostar a integridade de arquivos na ordem em que alguém digitou uma linha.
--
-- Estender é acrescentar o nome aqui, ou em vim.g.shpad_cobra.
local COBRA = { "gh", "docker", "kubectl", "helm", "podman", "hugo", "gitlab" }

-- Builtins que não estão no PATH. `cd`, `echo` e `test` existem em /bin no
-- macOS e vêm da varredura; estes não existem como arquivo em lugar nenhum.
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

local MAX_ITEMS = 500

local path_cache

-- Todo executável do PATH, uma vez por sessão. Não confere permissão de
-- execução por arquivo: seriam milhares de stat() para tirar meia dúzia de
-- não-executáveis que ninguém ia digitar de qualquer forma.
local function commands()
    if path_cache then
        return path_cache
    end

    local seen, out = {}, {}
    for _, name in ipairs(BUILTINS) do
        seen[name] = true
        out[#out + 1] = { label = name, kind = 14, detail = "builtin" }
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
                out[#out + 1] = { label = name, kind = 3, detail = dir }
            end
        end
    end

    path_cache = out
    return out
end

-- Quebra a linha em palavras do jeito mais ingênuo possível: sem aspas, sem
-- expansão. Serve para saber em qual comando você está e o que já digitou, e
-- não para entender a linha. Espaço no fim significa uma palavra nova, vazia.
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

local function allowed(cmd)
    for _, name in ipairs(vim.g.shpad_cobra or COBRA) do
        if name == cmd then
            return true
        end
    end
    return false
end

-- Uma linha por candidato, `valor<TAB>descrição`, terminando numa diretiva
-- `:<n>` que não é candidato nenhum.
local function parse_cobra(stdout)
    local items = {}
    for line in (stdout or ""):gmatch("[^\n]+") do
        if line:sub(1, 1) == ":" then
            break
        end
        local value, desc = line:match("^([^\t]+)\t?(.*)$")
        if value and value ~= "" then
            items[#items + 1] = {
                label = value,
                documentation = desc ~= "" and desc or nil,
            }
            if #items >= MAX_ITEMS then
                break
            end
        end
    end
    return items
end

local source = {}

function source.new()
    return setmetatable({}, { __index = source })
end

function source:is_available()
    return vim.bo.filetype == "sh"
end

-- Uma corrida de não-espaços, para que `--repo` e `./caminho` sejam uma palavra
-- só. O padrão do cmp pararia no hífen e na barra.
function source:get_keyword_pattern()
    return [[\S\+]]
end

function source:get_trigger_characters()
    return { "-", "/" }
end

function source:complete(params, callback)
    -- Uma consulta por vez: a anterior perdeu a validade assim que a linha
    -- mudou, e esperar por ela só atrasaria esta.
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

    local cmd = w[1]
    if not allowed(cmd) or vim.fn.executable(cmd) ~= 1 then
        return callback(nil)
    end

    local argv = { cmd, "__complete" }
    for i = 2, #w do
        argv[#argv + 1] = w[i]
    end

    self.job = vim.system(argv, { text = true }, function(res)
        self.job = nil
        local items = res.code == 0 and parse_cobra(res.stdout) or {}
        vim.schedule(function()
            callback(#items > 0 and items or nil)
        end)
    end)
end

M.source = source
return M
