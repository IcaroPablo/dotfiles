-- Ponte entre os specs no formato lazy (lua/plugins/*.lua, que não mudam) e o
-- vim.pack nativo do 0.12: de cada spec extrai só o que o vim.pack entende --
-- repositório, versão e build -- e guarda o config para rodar depois.

local M = {}

local PRIORITY = 50

local specs, configs, builds, visto = {}, {}, {}, {}

local function url(repo)
    return repo:find("://", 1, true) and repo or ("https://github.com/" .. repo)
end

local function collect(spec)
    if type(spec) == "string" then
        spec = { spec }
    end
    if type(spec) ~= "table" then
        return
    end
    -- um arquivo pode devolver uma lista de specs em vez de um só
    if type(spec[1]) == "table" then
        for _, s in ipairs(spec) do
            collect(s)
        end
        return
    end
    if type(spec[1]) ~= "string" then
        return
    end

    -- dependências antes do pai: o config do pai costuma requerer o filho
    for _, dep in ipairs(spec.dependencies or {}) do
        collect(dep)
    end

    local name = spec.name or spec[1]:match("[^/]+$")
    if visto[name] then
        return
    end
    visto[name] = true

    specs[#specs + 1] = { src = url(spec[1]), name = name, version = spec.branch or spec.commit or spec.tag }
    builds[name] = spec.build
    if spec.config then
        configs[#configs + 1] = { run = spec.config, prioridade = spec.priority or PRIORITY, ordem = #configs }
    end
end

local function build(ev)
    local cmd = builds[ev.data.spec.name]
    if not cmd or ev.data.kind == "delete" then
        return
    end
    if cmd:sub(1, 1) == ":" then
        -- comando do próprio plugin: numa instalação nova ele ainda não foi
        -- carregado, e o comando não existiria
        if not ev.data.active then
            vim.cmd.packadd(ev.data.spec.name)
        end
        vim.cmd(cmd:sub(2))
    else
        vim.system({ "sh", "-c", cmd }, { cwd = ev.data.path }):wait()
    end
end

local SUBS = { "update", "status", "clean", "del" }

local function orfaos()
    local nomes = {}
    for _, p in ipairs(vim.pack.get()) do
        if not p.active then
            nomes[#nomes + 1] = p.spec.name
        end
    end
    return nomes
end

local function comandos()
    vim.api.nvim_create_user_command("Pack", function(a)
        local sub = a.fargs[1] or "status"
        local nomes = vim.list_slice(a.fargs, 2)
        if sub == "update" then
            vim.pack.update(#nomes > 0 and nomes or nil)
        elseif sub == "status" then
            vim.pack.update(nil, { offline = true })
        elseif sub == "del" then
            if #nomes > 0 then
                vim.pack.del(nomes)
            end
        elseif sub == "clean" then
            local sobrando = orfaos()
            if #sobrando == 0 then
                vim.notify("nenhum plugin fora dos specs")
            elseif vim.fn.confirm("remover " .. table.concat(sobrando, ", ") .. "?", "&sim\n&nao", 2) == 1 then
                vim.pack.del(sobrando)
            end
        else
            vim.notify("subcomandos: " .. table.concat(SUBS, ", "), vim.log.levels.ERROR)
        end
    end, {
        nargs = "*",
        complete = function(lead, linha)
            -- ainda no primeiro argumento: completa o subcomando
            local candidatos = linha:match("^%S+%s+%S*$") and SUBS
                or linha:match("^Pack%s+del%s") and orfaos()
                or vim.tbl_map(function(p)
                    return p.spec.name
                end, vim.pack.get(nil, { info = false }))
            return vim.tbl_filter(function(c)
                return c:find(lead, 1, true) == 1
            end, candidatos)
        end,
    })
end

function M.setup()
    comandos()
    for _, file in ipairs(vim.api.nvim_get_runtime_file("lua/plugins/*.lua", true)) do
        collect(require("plugins." .. vim.fn.fnamemodify(file, ":t:r")))
    end

    -- antes do add: numa máquina nova o PackChanged de install dispara de
    -- dentro dele
    vim.api.nvim_create_autocmd("PackChanged", { callback = build })
    vim.pack.add(specs, { confirm = false })

    table.sort(configs, function(a, b)
        if a.prioridade ~= b.prioridade then
            return a.prioridade > b.prioridade
        end
        return a.ordem < b.ordem
    end)
    for _, c in ipairs(configs) do
        c.run()
    end
end

return M
