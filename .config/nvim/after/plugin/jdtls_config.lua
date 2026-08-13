-- Config nativa do jdtls (vim.lsp), sem nvim-jdtls.
-- Usa uma chamada explícita `vim.lsp.config` (prioridade sobre o lsp/jdtls.lua
-- que o nvim-lspconfig ships, cujo cmd é o wrapper Python). cmd manual (java
-- direto, flags do launcher oficial) + auto-bootstrap do eclipse.jdt.ls e do
-- lombok; workspace por projeto via config.root_dir.
local home = os.getenv("HOME")
local lombok = vim.fn.stdpath("data") .. "/lombok.jar"
local jdtls_url = "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"

local function jdtls_home()
    return os.getenv("JDTLS_HOME") or (home .. "/.local/share/jdtls-install")
end

local function launcher_jar()
    return vim.fn.glob(jdtls_home() .. "/plugins/org.eclipse.equinox.launcher_*.jar")
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
    local dir = home .. "/.sdkman/candidates/java"
    local out, seen = {}, {}
    if vim.fn.isdirectory(dir) == 0 then
        return out
    end
    for name in vim.fs.dir(dir) do
        local major = name:match("^(%d+)%.")
        if major and not seen[major] then
            seen[major] = true
            local env = (major == "8") and "JavaSE-1.8" or ("JavaSE-" .. major)
            table.insert(out, { name = env, path = dir .. "/" .. name })
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
        local data_dir = home .. "/.local/share/jdtls/" .. project
        local java = os.getenv("JAVA_HOME") and (os.getenv("JAVA_HOME") .. "/bin/java") or "java"
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
