-- Config nativa do jdtls (vim.lsp), sem nvim-jdtls.
-- Usa uma chamada explícita `vim.lsp.config` (prioridade sobre o lsp/jdtls.lua
-- que o nvim-lspconfig ships, cujo cmd é o wrapper Python). cmd manual (java
-- direto, flags do launcher oficial) + auto-bootstrap do eclipse.jdt.ls e do
-- lombok; workspace por projeto via config.root_dir.
local home = vim.env.HOME
local lombok = vim.fs.joinpath(vim.fn.stdpath("data"), "lombok.jar")
local jdtls_url = "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"

local function jdtls_home()
    return vim.env.JDTLS_HOME or vim.fs.joinpath(home, ".local", "share", "jdtls-install")
end

local function launcher_jar()
    return vim.fn.glob(vim.fs.joinpath(jdtls_home(), "plugins", "org.eclipse.equinox.launcher_*.jar"))
end

-- baixa o lombok.jar uma vez
local function bootstrap_lombok()
    if vim.fn.filereadable(lombok) == 0 and vim.fn.executable("curl") == 1 then
        vim.notify("baixando lombok.jar…", vim.log.levels.INFO)
        vim.fn.system({ "curl", "-fsSL", "-o", lombok, "https://projectlombok.org/downloads/lombok.jar" })
    end
end

-- baixa/extrai o eclipse.jdt.ls uma vez, se ainda não houver launcher
local function bootstrap_jdtls()
    if launcher_jar() ~= "" or vim.fn.executable("curl") == 0 or vim.fn.executable("tar") == 0 then
        return
    end
    vim.notify("baixando eclipse.jdt.ls (~50MB)…", vim.log.levels.INFO)
    local tarball = vim.fn.tempname() .. ".tar.gz"
    vim.fn.system({ "curl", "-fsSL", "-o", tarball, jdtls_url })
    if vim.v.shell_error == 0 then
        vim.fn.mkdir(jdtls_home(), "p")
        vim.fn.system({ "tar", "-xzf", tarball, "-C", jdtls_home() })
    end
    vim.fn.delete(tarball)
end

-- runtimes de projeto: descobre os JDKs do sdkman (à prova de bump de patch)
local function sdkman_runtimes()
    local dir = vim.fs.joinpath(home, ".sdkman", "candidates", "java")
    local out, seen = {}, {}
    if vim.fn.isdirectory(dir) == 0 then
        return out
    end
    for name in vim.fs.dir(dir) do
        local major = name:match("^(%d+)%.")
        if major and not seen[major] then
            seen[major] = true
            local env = (major == "8") and "JavaSE-1.8" or ("JavaSE-" .. major)
            table.insert(out, { name = env, path = vim.fs.joinpath(dir, name) })
        end
    end
    return out
end

vim.lsp.config("jdtls", {
    filetypes = { "java" },
    root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "mvnw", "gradlew", "settings.gradle", ".git" },
    init_options = {},
    settings = {
        java = {
            ["signatureHelp.enabled"] = true,
            ["contentProvider.preferred"] = "fernflower",
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "java.util.Collections",
                    "org.mockito.Mockito.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            },
            configuration = {
                runtimes = sdkman_runtimes(),
            },
            codeGeneration = {
                ["toString.template"] = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                ["hashCodeEquals.useJava7Objects"] = true,
                useBlocks = true,
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
        },
    },
    cmd = function(dispatchers, config)
        bootstrap_lombok()
        bootstrap_jdtls()
        local launcher = launcher_jar()
        if launcher == "" then
            vim.notify("eclipse.jdt.ls indisponível — checar curl/tar/rede ou $JDTLS_HOME", vim.log.levels.ERROR)
            error("jdtls: launcher não encontrado")
        end
        local project = config.root_dir and vim.fn.fnamemodify(config.root_dir, ":p:h:t") or "default"
        local data_dir = vim.fs.joinpath(home, ".local", "share", "jdtls", project)
        local java = vim.env.JAVA_HOME and vim.fs.joinpath(vim.env.JAVA_HOME, "bin", "java") or "java"
        local argv = {
            java,
            "-Djdk.xml.maxGeneralEntitySizeLimit=0",
            "-Djdk.xml.totalEntitySizeLimit=0",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dosgi.checkConfiguration=true",
            "-Dosgi.sharedConfiguration.area=" .. jdtls_home() .. "/config_linux",
            "-Dosgi.sharedConfiguration.area.readOnly=true",
            "-Dosgi.configuration.cascaded=true",
            "-Xms1G",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
        }
        if vim.fn.filereadable(lombok) == 1 then
            table.insert(argv, "-javaagent:" .. lombok)
        end
        vim.list_extend(argv, { "-jar", launcher, "-data", data_dir })
        return vim.lsp.rpc.start(argv, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
        })
    end,
})

-- ── Keymaps de Java ──────────────────────────────────────────────────────────
-- Presos ao LspAttach do jdtls e não ao FileType: os quatro de refactor são code
-- action do servidor, e os dois de teste precisam de um pom.xml — nenhum faz
-- sentido num .java solto sem projeto.

local map = require("core.map")
local root = require("core.root")

-- prefere o `mvn` do PATH; se ausente, cai pro ./mvnw do projeto
local function maven_bin()
    if vim.fn.executable("mvn") == 1 then
        return "mvn"
    end
    local wroot = root.nearest({ "mvnw" })
    local mvnw = wroot and vim.fs.joinpath(wroot, "mvnw")
    if mvnw and vim.fn.executable(mvnw) == 1 then
        return mvnw
    end
    return nil
end

--- Nome do método sob o cursor, perguntado ao jdtls. Vem do compilador, então
--- acerta genérico, sobrecarga e classe interna sem depender de o treesitter
--- estar instalado nem de a query casar com a gramática.
local METHOD, CONSTRUCTOR = 6, 9

local function enclosing_method()
    local res = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", { textDocument = vim.lsp.util.make_text_document_params() }, 2000)
    local linha = vim.api.nvim_win_get_cursor(0)[1] - 1
    local achado

    -- o mais interno vence: a recursão desce e sobrescreve o de fora
    local function procura(itens)
        for _, s in ipairs(itens or {}) do
            local r = s.range or (s.location or {}).range
            if r and r.start.line <= linha and linha <= r["end"].line then
                if s.kind == METHOD or s.kind == CONSTRUCTOR then
                    achado = s.name:gsub("%(.*", "")
                end
                procura(s.children)
            end
        end
    end

    for _, r in pairs(res or {}) do
        procura(r.result)
    end
    return achado
end

-- roda `mvn test -Dtest=<spec>` da raiz do projeto num split de terminal
local function run_maven_test(spec)
    local pom_dir = root.nearest({ "pom.xml" })
    if not pom_dir then
        vim.notify("pom.xml não encontrado (raiz do projeto)", vim.log.levels.WARN)
        return
    end
    local mvn = maven_bin()
    if not mvn then
        vim.notify("nem `mvn` nem `./mvnw` encontrados", vim.log.levels.ERROR)
        return
    end
    vim.cmd("botright new")
    vim.cmd("resize 18")
    vim.fn.jobstart({ mvn, "test", "-Dtest=" .. spec }, { cwd = pom_dir, term = true })
end

-- code action de kind específico, aplicada direto
local function code_action(kind)
    return function()
        vim.lsp.buf.code_action({ context = { only = { kind } }, apply = true })
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("jdtls_keymaps", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "jdtls" then
            return
        end
        local opts = { buffer = args.buf }

        map.set("n", "<leader>jtc", function()
            run_maven_test(vim.fn.expand("%:t:r"))
        end, opts)
        map.set("n", "<leader>jtm", function()
            local m = enclosing_method()
            if not m then
                vim.notify("nenhum método sob o cursor", vim.log.levels.WARN)
                return
            end
            run_maven_test(vim.fn.expand("%:t:r") .. "#" .. m)
        end, opts)

        map.set("n", "<leader>jdi", code_action("source.organizeImports"), opts)
        map.set({ "n", "v" }, "<leader>jev", code_action("refactor.extract.variable"), opts)
        map.set("v", "<leader>jec", code_action("refactor.extract.constant"), opts)
        map.set("v", "<leader>jem", code_action("refactor.extract.method"), opts)
    end,
})
