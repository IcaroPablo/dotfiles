-- verificar instalação do jdtls ??????????

local on_attach = function(client, bufnr)

    -- require'jdtls.setup'.add_commands()
    -- require'jdtls'.setup_dap()
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

-- local workspace_folder = home .. "/Workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local home = os.getenv('HOME')
local jdtls_config = {
    cmd = { '.local/share/nvim/mason/bin/jdtls' },
    -- cmd = { home .. '/.sdkman/candidates/java/17.0.5-oracle/bin/java',
    --         '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    --         '-Dosgi.bundles.defaultStartLevel=4',
    --         '-Declipse.product=org.eclipse.jdt.ls.core.product',
    --         '-Dlog.protocol=true',
    --         '-Dlog.level=ALL',
    --         '-Xms1g',
    --         '--add-modules=ALL-SYSTEM',
    --         '--add-opens java.base/java.util=ALL-UNNAMED',
    --         '--add-opens java.base/java.lang=ALL-UNNAMED',
    --         '-jar', home .. '.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
    --         '-configuration', home .. '.local/share/nvim/mason/packages/jdtls/config_linux',
    --         '-data ~/Workspace/conta_azul'
    --     },
    -- cmd = {
    --     -- '/path/to/java17_or_newer/bin/java'
    --     home .. '.sdkman/candidates/java/17.0.5-oracle/bin/java',
    --     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    --     '-Dosgi.bundles.defaultStartLevel=4',
    --     '-Declipse.product=org.eclipse.jdt.ls.core.product',
    --     '-Dlog.protocol=true',
    --     '-Dlog.level=ALL',
    --     '-Xms1g',
    --     '--add-modules=ALL-SYSTEM',
    --     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    --     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    --     -- jdtls jar
    --     '-jar', home .. '.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar',
    --     -- Change to one of `linux`, `win` or `mac` Depending on your system.
    --     '-configuration', home .. '.local/share/nvim/mason/packages/jdtls/config_linux',
    --     '-data', workspace_folder
    -- },
    -- flags = { allow_incremental_sync = true },
    -- init_options = {
    --     bundles = bundles;
    --     extendedClientCapabilities = require'jdtls'.extendedClientCapabilities({
    --         resolveAdditionalTextEditsSupport = true
    --     })
    -- },
    settings = {
    -- ['java.format.settings.url'] = home .. "/.config/nvim/language-servers/java-google-formatter.xml",
    -- ['java.format.settings.profile'] = "GoogleStyle",
        java = {
        -- signatureHelp = { enabled = true },
        -- contentProvider = { preferred = 'fernflower' },
        -- completion = {
        --     favoriteStaticMembers = {
        --         "org.hamcrest.MatcherAssert.assertThat",
        --         "org.hamcrest.Matchers.*",
        --         "org.hamcrest.CoreMatchers.*",
        --         "org.junit.jupiter.api.Assertions.*",
        --         "java.util.Objects.requireNonNull",
        --         "java.util.Objects.requireNonNullElse",
        --         "org.mockito.Mockito.*"
        --     }
        -- },
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-1.8",
                        path = home .. '/.sdkman/candidates/java/8.0.302-open/'
                    },
                    {
                        name = "JavaSE-11",
                        path = home .. '/.sdkman/candidates/java/11.0.12-open/'
                    },
                    {
                        name = 'JavaSE-17',
                        path = home .. '/.sdkman/candidates/java/17.0.5-oracle/'
                    }
                }
            },
            -- codeGeneration = {
            --     toString = {
            --         template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
            --     }
            -- },
            -- sources = {
            --     organizeImports = {
            --         starThreshold = 9999,
            --         staticStarThreshold = 9999
            --     }
            -- }
        }
    },
    -- capabilities = caps,
    -- capabilities = {
    --     workspace = {
    --         configuration = true
    --     },
    --     textDocument = {
    --         completion = {
    --             completionItem = {
    --                 snippetSupport = true
    --             }
    --         }
    --     }
    -- },
    on_attach = on_attach,
    root_dir = require('jdtls.setup').find_root({'.gradlew', 'pom.xml', '.git', 'mvnw'}),
    -- root_dir = lspconfig.util.root_pattern(".git", "pom.xml"),
    -- root_dir = vim.fs.dirname(vim.fs.find({ '.gradlew', 'pom.xml', '.git', 'mvnw'}, { upward = true })[1]),
    -- -- This is currently required to have the server read the settings, In a future neovim build this may no longer be required
    -- on_init = function(client) client.notify('workspace/didChangeConfiguration', { settings = settings }) end
    -- on_init = function(client, _) client.notify('workspace/didChangeConfiguration', { settings = config.settings }) end
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        require('jdtls').start_or_attach(jdtls_config)
    end
})

-- vim.cmd([[
--     augroup jdtls_lsp
--     autocmd!
--     autocmd FileType java lua require('jdtls_setup').setup()
--     augroup end
-- ]])

