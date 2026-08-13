local caps = require("cmp_nvim_lsp").default_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true

-- Config global aplicada a todos os servers (modelo nativo vim.lsp)
vim.lsp.config("*", {
    capabilities = caps,
    on_init = function(client)
        -- desliga os semantic tokens do LSP para não sobrescrever as cores do treesitter
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

-- Keymaps por buffer quando um LSP anexa (:h lsp-attach)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufopts = { noremap = true, silent = true, buffer = args.buf }

        vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, bufopts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, bufopts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, bufopts)

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        -- vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        -- vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        -- vim.keymap.set("n", "<Leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
        -- vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<Leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, bufopts)
    end,
})

-- -- Python
-- lspconfig.pyright.setup({
--     capabilities = caps,
--     on_attach = on_attach_config
-- })

-- -- JavaScript/Typescript
-- lspconfig.ts_ls.setup({
--     capabilities = caps,
--     on_attach = on_attach_config
-- })

-- -- C
-- lspconfig.clangd.setup({
--     capabilities = caps,
--     on_attach = on_attach_config
-- })

local servers = {
    "pyright",
    "ts_ls",
    "clangd",
    -- "vimls",
    -- "bashls"
}

vim.lsp.config("texlab", {
    cmd = { "texlab" },
    filetypes = { "tex", "bib" },
    settings = {
        texlab = {
            auxDirectory = ".",
            bibtexFormatter = "texlab",
            build = {
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f", "-shell-escape" },
                executable = "latexmk",
                forwardSearchAfter = true,
                onSave = true,
            },
            chktex = {
                onEdit = true,
                onOpenAndSave = true,
            },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            forwardSearch = {
                executable = "zathura",
                args = {
                    "--synctex-editor-command",
                    [[nvim --headless -c 'TexlabInverseSearch %{input} %{line}']],
                    "--synctex-forward",
                    "%l:1:%f",
                    "%p",
                },
            },
            latexFormatter = "latexindent",
            latexindent = {
                modifyLineBreaks = false,
            },
        },
    },
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
            -- root_dir = root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git")
        },
    },
    -- cmd = {os.getenv('HOME') .. '/lua-language-server-rust/target/release/lua-language-server'},
    -- cmd = {'/usr/local/bin/lua-language-server'},
    -- cmd = {'/usr/local/lib/lua-language-server/bin/lua-language-server'},
    cmd = { "lua-language-server" },
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

vim.lsp.enable(servers)
vim.lsp.enable({ "texlab", "lua_ls" })

---------------------------------
-- Floating diagnostics message
---------------------------------
vim.diagnostic.config({
    float = {
        -- source = "always",
        -- source = "if_many",
        source = true,
        -- show_header = false,
        -- border = border
    },
    underline = false,
    virtual_text = false,
    signs = true,
    --[[ virtual_text = {
        show = false,
		prefix = "",
	}, ]]
    -- update_in_insert = false,
    -- severity_sort = true,
})

-- vim.cmd([[ autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
--
-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	buffer = bufnr,
-- 	callback = function()
-- 		local opts = {
-- 			focusable = false,
-- 			close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
-- 			border = "rounded",
-- 			source = "if_many",
-- 			prefix = " ",
-- 			header = "",
-- 			scope = "cursor",
-- 			focus = false,
-- 		}
-- 		vim.diagnostic.open_float(nil, opts)
-- 	end,
-- })
--
