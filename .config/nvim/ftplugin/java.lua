-- Rodar testes via Maven num terminal buffer.
-- Prefere `mvn`; se ausente, cai pro `./mvnw` do projeto; erro se nenhum.
local function maven_bin()
    if vim.fn.executable("mvn") == 1 then
        return "mvn"
    end
    local wroot = vim.fs.root(0, { "mvnw" })
    if wroot and vim.fn.executable(wroot .. "/mvnw") == 1 then
        return wroot .. "/mvnw"
    end
    return nil
end

-- nome do método de teste sob o cursor (via treesitter)
local function enclosing_method()
    local ok, parser = pcall(vim.treesitter.get_parser, 0, "java")
    if not ok or not parser then
        return nil
    end
    parser:parse()
    local node = vim.treesitter.get_node()
    while node do
        if node:type() == "method_declaration" then
            local name = node:field("name")[1]
            if name then
                return vim.treesitter.get_node_text(name, 0)
            end
        end
        node = node:parent()
    end
    return nil
end

-- roda `mvn test -Dtest=<spec>` da raiz do projeto num split de terminal
local function run_maven_test(spec)
    local root = vim.fs.root(0, { "pom.xml" })
    if not root then
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
    vim.fn.termopen({ mvn, "test", "-Dtest=" .. spec }, { cwd = root })
end

local function maven_test_class()
    run_maven_test(vim.fn.expand("%:t:r"))
end

local function maven_test_method()
    local m = enclosing_method()
    if not m then
        vim.notify("nenhum método de teste sob o cursor", vim.log.levels.WARN)
        return
    end
    run_maven_test(vim.fn.expand("%:t:r") .. "#" .. m)
end

local on_attach = function(client, bufnr)
    local nore_silent = { noremap = true, silent = true }

    vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, nore_silent)
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1 })
    end, nore_silent)
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1 })
    end, nore_silent)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    -- vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set("n", "<Leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<Leader>cf", function()
        vim.lsp.buf.format({ async = true })
    end, bufopts)

    -- vim.keymap.set("n", "<Leader>jtb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>jsb", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", bufopts)
    -- vim.keymap.set("n", '<Leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>", "Clear breakpoints")
    -- vim.keymap.set("n", '<Leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "List breakpoints")

    -- vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<cr>", "Step over")
    -- vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_into()<cr>", "Step into")
    -- vim.keymap.set("n", "<Leader>do", "<cmd>lua require'dap'.step_out()<cr>", "Step out")
    -- vim.keymap.set("n", '<Leader>dd', "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect")
    -- vim.keymap.set("n", '<Leader>dt', "<cmd>lua require'dap'.terminate()<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>dl", "<cmd>lua require'dap'.run_last()<cr>", "Run last")
    -- vim.keymap.set("n", '<Leader>di', function() require"dap.ui.widgets".hover() end, "Variables")
    -- vim.keymap.set("n", '<Leader>d?', function() local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes) end, "Scopes")
    -- vim.keymap.set("n", '<Leader>df', '<cmd>Telescope dap frames<cr>', "List frames")
    -- vim.keymap.set("n", '<Leader>dh', '<cmd>Telescope dap commands<cr>', "List commands")

    -- map("n", "<leader>er", "<cmd>lua require'dapui'.toggle()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>es", "<cmd>lua require'dap'.continue()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eu", "<cmd>lua require'dap'.step_over()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>ei", "<cmd>lua require'dap'.step_into()<CR>", { silent = true, noremap = true })
    -- map("n", "<F4>", "<cmd>lua require'dap'.step_into()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eo", "<cmd>lua require'dap'.step_out()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eb", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>ec", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>ef", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", { silent = true, noremap = true })

    vim.keymap.set("n", "<leader>jdi", require("jdtls").organize_imports, bufopts)
    vim.keymap.set("n", "<leader>jev", require("jdtls").extract_variable, bufopts)
    vim.keymap.set("v", "<leader>jev", function()
        require("jdtls").extract_variable({ true, "variable" })
    end, bufopts)
    vim.keymap.set("v", "<Leader>jec", function()
        require("jdtls").extract_constant({ true, "constant" })
    end, bufopts)
    vim.keymap.set("v", "<leader>jem", function()
        require("jdtls").extract_method({
            true,
            function()
                return "extracted"
            end,
        })
    end, bufopts)

    vim.keymap.set("n", "<leader>jtc", maven_test_class, bufopts)
    vim.keymap.set("n", "<leader>jtm", maven_test_method, bufopts)
end

-----------------------------------------------------------------------------------------------------------------------

-- local finders = require'telescope.finders'
-- local sorters = require'telescope.sorters'
-- local actions = require'telescope.actions'
-- local pickers = require'telescope.pickers'

-- require('jdtls.ui').pick_one_async = function(items, prompt, label_fn, cb)
--     local opts = {}
--     pickers.new(opts, {
--         prompt_title = prompt,
--         finder    = finders.new_table {
--             results = items,
--             entry_maker = function(entry)
--                 return {
--                     value = entry,
--                     display = label_fn(entry),
--                     ordinal = label_fn(entry),
--                 }
--             end,
--         },
--         sorter = sorters.get_generic_fuzzy_sorter(),
--         attach_mappings = function(prompt_bufnr)
--             actions.goto_file_selection_edit:replace(function()
--                 local selection = actions.get_selected_entry(prompt_bufnr)
--                 actions.close(prompt_bufnr)

--                 cb(selection.value)
--             end)

--             return true
--         end,
--     }):find()
-- end

-----------------------------------------------------------------------------------------------------------------------

local home = os.getenv("HOME")

-- bootstrap do lombok: download único, anexado como javaagent do jdtls
local lombok = vim.fn.stdpath("data") .. "/lombok.jar"
if vim.fn.filereadable(lombok) == 0 and vim.fn.executable("curl") == 1 then
    vim.notify("baixando lombok.jar…", vim.log.levels.INFO)
    vim.fn.system({ "curl", "-fsSL", "-o", lombok, "https://projectlombok.org/downloads/lombok.jar" })
end
-- local workspace_folder = lspconfig.util.root_pattern(".git", "pom.xml"),
-- local workspace_folder = require('jdtls.setup').find_root({'.gradlew', 'pom.xml', '.git', 'mvnw'})
-- local workspace_folder = home .. "/Workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
-- local workspace_folder = vim.fs.dirname(vim.fs.find({'.gradlew', 'pom.xml', '.git', 'mvnw'}, { upward = true })[1])
local project_folder = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml" }) or ""

-- local caps = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

capabilities.workspace = {
    configuration = true,
    ["didChangeWatchedFiles.dynamicRegistration"] = true,
    ["didChangeConfiguration.dynamicRegistration"] = true,
    ["textDocument.completion.completionItem.snippetSupport"] = true,
}

local workspace = home .. "/.local/share/jdtls/" .. vim.fn.fnamemodify(project_folder, ":p:h:t")

-- eclipse.jdt.ls: usa $JDTLS_HOME, senão instala em ~/.local/share/jdtls-install (bootstrap).
local jdtls_url = "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"
local jdtls_home = os.getenv("JDTLS_HOME") or (home .. "/.local/share/jdtls-install")
local function jdtls_launcher()
    return vim.fn.glob(jdtls_home .. "/plugins/org.eclipse.equinox.launcher_*.jar")
end

-- bootstrap: baixa e extrai o eclipse.jdt.ls uma vez, se ainda não houver launcher
if jdtls_launcher() == "" and vim.fn.executable("curl") == 1 and vim.fn.executable("tar") == 1 then
    vim.notify("baixando eclipse.jdt.ls (~50MB)…", vim.log.levels.INFO)
    local tarball = vim.fn.tempname() .. ".tar.gz"
    vim.fn.system({ "curl", "-fsSL", "-o", tarball, jdtls_url })
    if vim.v.shell_error == 0 then
        vim.fn.mkdir(jdtls_home, "p")
        vim.fn.system({ "tar", "-xzf", tarball, "-C", jdtls_home })
    end
    vim.fn.delete(tarball)
end

local launcher = jdtls_launcher()
if launcher == "" then
    vim.notify("eclipse.jdt.ls indisponível (checar curl/tar/rede) — ou defina $JDTLS_HOME", vim.log.levels.WARN)
    return
end

-- Flags copiadas do launcher oficial (jdtls.py) — sem depender do wrapper Python.
-- config_linux é OS-agnóstico (jdtls é Java puro) e entra como shared config read-only,
-- então roda igual nos 3 SOs sem condicional; a config gravável vai pro -data.
local java = os.getenv("JAVA_HOME") and (os.getenv("JAVA_HOME") .. "/bin/java") or "java"
local cmd = {
    java,
    "-Djdk.xml.maxGeneralEntitySizeLimit=0", -- exigido no Java 24+, inócuo antes
    "-Djdk.xml.totalEntitySizeLimit=0",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dosgi.checkConfiguration=true",
    "-Dosgi.sharedConfiguration.area=" .. jdtls_home .. "/config_linux",
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
    table.insert(cmd, "-javaagent:" .. lombok)
end
vim.list_extend(cmd, { "-jar", launcher, "-data", workspace })

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

local jdtls_config = {
    cmd = cmd,
    flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 80,
    },
    init_options = {
        -- extendedClientCapabilities = require'jdtls'.extendedClientCapabilities({
        --     resolveAdditionalTextEditsSupport = true
        -- })
    },
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
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = project_folder,
}

require("jdtls").start_or_attach(jdtls_config)
