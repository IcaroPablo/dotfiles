-- verificar instalação do jdtls ??????????

local on_attach = function(client, bufnr)

    -- require'jdtls.setup'.add_commands()
    -- require'jdtls'.setup_dap()
    -- require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    require('mappings').setup_nvim_lsp()
    require('mappings').setup_nvim_lsp_on_attach(bufnr)
    require('mappings').setup_jdtls(bufnr)

-----------------------------------------------------------------------------------------------------------------------

    -- require'lsp-status'.register_progress()

    -- require'compe'.setup {
    --     enabled = true;
    --     autocomplete = true;
    --     debug = false;
    --     min_length = 1;
    --     preselect = 'enable';
    --     throttle_time = 80;
    --     source_timeout = 200;
    --     incomplete_delay = 400;
    --     max_abbr_width = 100;
    --     max_kind_width = 100;
    --     max_menu_width = 100;
    --     documentation = true;

    --     source = {
    --         path = true;
    --         buffer = true;
    --         calc = true;
    --         vsnip = false;
    --         nvim_lsp = true;
    --         nvim_lua = true;
    --         spell = true;
    --         tags = true;
    --         snippets_nvim = false;
    --         treesitter = true;
    --     };
    -- }

    -- require'lspkind'.init()
    -- require'lspsaga'.init_lsp_saga()

    -- require'formatter'.setup{
    --     filetype = {
    --         java = {
    --             function()
    --                 return {
    --                     exe = 'java',
    --                     args = { '-jar', os.getenv('HOME') .. '/.local/jars/google-java-format.jar', vim.api.nvim_buf_get_name(0) },
    --                     stdin = true
    --                 }
    --             end
    --         }
    --     }
    -- }

-----------------------------------------------------------------------------------------------------------------------

    -- vim.api.nvim_exec([[
    --     augroup FormatAutogroup
    --     autocmd!
    --     autocmd BufWritePost *.java FormatWrite
    --     augroup end
    -- ]], true)

    -- vim.api.nvim_exec([[
    --     hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
    --     hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
    --     hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
    --     augroup lsp_document_highlight
    --     autocmd!
    --     autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    --     autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    --     augroup END
    -- ]], false)

end

-----------------------------------------------------------------------------------------------------------------------

-- UI
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
local jdtls_folder = home .. '/.local/share/nvim/mason/packages/jdtls/'
local config_folder = jdtls_folder .. 'config_linux/'
-- local workspace_folder = lspconfig.util.root_pattern(".git", "pom.xml"),
-- local workspace_folder = require('jdtls.setup').find_root({'.gradlew', 'pom.xml', '.git', 'mvnw'})
-- local workspace_folder = home .. "/Workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
-- local workspace_folder = vim.fs.dirname(vim.fs.find({'.gradlew', 'pom.xml', '.git', 'mvnw'}, { upward = true })[1])
local project_folder = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})

local bundles = {
    vim.fn.glob(home .. '/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
};

vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/vscode-java-test/server/*.jar", 1), "\n"))

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
                    url = "/.local/share/eclipse/eclipse-java-google-style.xml",
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
                        path = '/usr/local/jdk-17/'
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
