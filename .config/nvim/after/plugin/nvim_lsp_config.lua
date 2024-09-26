local lspconfig = require("lspconfig")
local caps = vim.lsp.protocol.make_client_capabilities()

local on_attach_config = function(client, bufnr)
    client.server_capabilities.document_formatting = false
    require('mappings').setup_nvim_lsp_on_attach(bufnr)
end

-- Capabilities
caps.textDocument.completion.completionItem.snippetSupport = true

-- Python
lspconfig.pyright.setup({
    capabilities = caps,
    on_attach = on_attach_config
})

-- JavaScript/Typescript
lspconfig.ts_ls.setup({
    capabilities = caps,
    on_attach = on_attach_config
})

-- C
lspconfig.clangd.setup({
    capabilities = caps,
    on_attach = on_attach_config
})

-- Rust
-- lspconfig.rust_analyzer.setup({
--     capabilities = snip_caps,
--     on_attach = on_attach_config
-- })

lspconfig.lua_ls.setup({
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false
            },
            -- root_dir = root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git")
        },
    },
    -- cmd = {os.getenv('HOME') .. '/.local/lua-language-server/bin/lua-language-server'},
    -- cmd = {'/usr/local/bin/lua-language-server'},
    -- cmd = {'/usr/local/lib/lua-language-server/bin/lua-language-server'},
    cmd = {'lua-language-server'},
    capabilities = caps,
    on_attach = on_attach_config
})

-- Emmet
-- lspconfig.emmet_ls.setup({
--     capabilities = snip_caps,
--     filetypes = {
--         "css",
--         "html",
--         "javascriptreact",
--         "less",
--         "sass",
--         "scss",
--         "typescriptreact"
--     }
-- })

---------------------------------
-- Floating diagnostics message
---------------------------------
vim.diagnostic.config({
    float = {
        -- source = "always",
        -- source = "if_many",
        source = true,
        -- border = border
    },
	underline = false,
    virtual_text = false,
    signs = true,
})

---------------------------------
-- Auto commands
---------------------------------
vim.cmd([[ autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

