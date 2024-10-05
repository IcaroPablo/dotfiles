local on_attach = function(client, bufnr)

    local nore_silent = { noremap = true, silent = true };

    vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, nore_silent)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({count = -1}) end, nore_silent)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({count = 1}) end, nore_silent)

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
    vim.keymap.set({"n", 'v'}, "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<Leader>cf", function() vim.lsp.buf.format({async = true}) end, bufopts)

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

    vim.keymap.set("n", "<leader>jdi", require('jdtls').organize_imports, bufopts)
    vim.keymap.set("n", "<leader>jev", require('jdtls').extract_variable, bufopts)
    vim.keymap.set("v", "<leader>jev", function() require('jdtls').extract_variable({true, 'variable'}) end, bufopts)
    vim.keymap.set('v', '<Leader>jec', function() require('jdtls').extract_constant({true, 'constant'}) end, bufopts)
    vim.keymap.set("v", "<leader>jem", function() require('jdtls').extract_method({true, function() return 'extracted' end}) end, bufopts)

    vim.keymap.set("n", "<leader>jtc", require('jdtls').test_class, bufopts)
    vim.keymap.set("n", "<leader>jtm", require('jdtls').test_nearest_method, bufopts)
    -- require("jdtls.tests").generate()
    -- require("jdtls.tests").goto_subjects()

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

local home = os.getenv('HOME')
local jdtls_folder = home .. '/.local/share/nvim/mason/packages/jdtls/' -- sensible (mason default)
local config_folder = jdtls_folder .. 'config_linux/'
-- local workspace_folder = lspconfig.util.root_pattern(".git", "pom.xml"),
-- local workspace_folder = require('jdtls.setup').find_root({'.gradlew', 'pom.xml', '.git', 'mvnw'})
-- local workspace_folder = home .. "/Workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
-- local workspace_folder = vim.fs.dirname(vim.fs.find({'.gradlew', 'pom.xml', '.git', 'mvnw'}, { upward = true })[1])
local project_folder = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"}) or ''

local bundles = {
    vim.fn.glob(home .. '/.local/share/nvim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar') --sensible
};

vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/.local/share/nvim/vscode-java-test/server/*.jar", true), "\n")) -- sensible

-- local caps = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

capabilities.workspace = {
    configuration = true,
    ['didChangeWatchedFiles.dynamicRegistration'] = true,
    ['didChangeConfiguration.dynamicRegistration'] = true,
    ['textDocument.completion.completionItem.snippetSupport'] = true
}

local jdtls_config = {
    cmd = {
        os.getenv('JAVA_HOME') .. '/bin/java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        -- '-Dosgi.checkConfiguration=true',
        '-Dlog.protocol=true',
        '-Dosgi.sharedConfiguration.area=' .. config_folder,
        -- '-Dosgi.sharedConfiguration.area.readOnly=true',
        -- '-Dosgi.configuration.cascaded=true',
        '-Dlog.level=ALL',
        -- '-Dorg.osgi.framework.os.name=my_os_name',
        '-javaagent:' .. jdtls_folder .. '/lombok.jar',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', vim.fn.glob(jdtls_folder .. 'plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', config_folder,
        -- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
        -- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        '-data', home .. '/.local/share/jdtls/' .. vim.fn.fnamemodify(project_folder, ':p:h:t')
    },
    flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 80
    },
    init_options = {
        -- extendedClientCapabilities = require'jdtls'.extendedClientCapabilities({
        --     resolveAdditionalTextEditsSupport = true
        -- })
        bundles = bundles
    },
    settings = {
        java = {
            ['signatureHelp.enabled'] = true,
            ['contentProvider.preferred'] = 'fernflower',
            format = {
                settings = {
                    -- Use Google Java style guidelines for formatting
                    -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
                    url = "/.local/share/eclipse/eclipse-java-google-style.xml", --sensible
                    profile = "GoogleStyle",
                },
            },
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*"
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
                runtimes = {
                    -- {
                    --     name = "JavaSE-1.8",
                    --     path = home .. '/.sdkman/candidates/java/8.0.302-open/'
                    -- },
                    -- {
                    --     name = "JavaSE-11",
                    --     path = home .. '/.sdkman/candidates/java/11.0.12-open/'
                    -- },
                    {
                        name = 'JavaSE-17',
                        path = '/usr/local/jdk-17/' -- sensible
                    }
                }
            },
            codeGeneration = {
                ['toString.template'] = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                ['hashCodeEquals.useJava7Objects'] = true,
                useBlocks = true
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999
                }
            }
        }
    },
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = project_folder
}

require('jdtls').start_or_attach(jdtls_config)
