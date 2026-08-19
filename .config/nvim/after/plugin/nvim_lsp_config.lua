-- ════════════════════════════════════════════════════════════════════════════
--  LSP — modelo nativo vim.lsp (neovim 0.11)
-- ════════════════════════════════════════════════════════════════════════════

-- ── Capabilities + config global (aplicada a todos os servers) ───────────────
local map = require("core.map")

local caps = require("cmp_nvim_lsp").default_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
    capabilities = caps,
    on_init = function(client)
        -- desliga os semantic tokens do LSP para não sobrescrever as cores do treesitter
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

-- ── Keymaps por buffer quando um LSP anexa (:h lsp-attach) ───────────────────
-- O 0.11 já traz: grn rename, gra code action, grr references, gri
-- implementation, grt type definition, gO document symbol, [d/]d salto de
-- diagnóstico, <C-W>d float do diagnóstico, <C-S> signature help em insert.
-- K hover (se keywordprg estiver vazio e ninguém mapear K antes). Também seta
-- tagfunc, omnifunc e formatexpr, então <C-]>, <C-x><C-o> e gq passam pelo LSP
-- sem mapeamento. Só fica aqui o que não tem default.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufopts = { buffer = args.buf }

        map.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        map.set("n", "gd", vim.lsp.buf.definition, bufopts)

        -- formatação roda no build, pelo terminal. Se precisar pontualmente,
        -- gq formata um range via formatexpr, sem mapeamento nenhum.
        -- map.set("n", "<Leader>cf", function()
        --     vim.lsp.buf.format({ async = true })
        -- end, bufopts)
    end,
})

-- ── Diagnósticos ─────────────────────────────────────────────────────────────
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

-- Com virtual_text desligado, a mensagem do diagnóstico só aparece sob demanda.
-- Este autocmd abre o float sozinho quando o cursor para, no intervalo do
-- 'updatetime'. Global de propósito: diagnóstico nem sempre vem de LSP, e
-- open_float não faz nada em buffer sem diagnóstico. Sem `border` nem `source`
-- aqui, para herdar o winborder e a vim.diagnostic.config acima.
vim.api.nvim_create_autocmd("CursorHold", {
    group = vim.api.nvim_create_augroup("diagnostic_float", { clear = true }),
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        })
    end,
})

-- ── Config por server (jdtls tem a sua em jdtls_config.lua) ───────────────────
vim.lsp.config("texlab", {
    cmd = { "texlab" },
    filetypes = { "tex", "bib" },
    root_markers = { ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml", ".git" },
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
    -- cmd = {os.getenv('HOME') .. '/lua-language-server-rust/target/release/lua-language-server'},
    -- cmd = {'/usr/local/bin/lua-language-server'},
    -- cmd = {'/usr/local/lib/lua-language-server/bin/lua-language-server'},
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
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
})

vim.lsp.config("clangd", {
    -- Um binário só, já no PATH (Apple clangd 21) — nada do bootstrap que o
    -- jdtls precisa. Por isso mora aqui, junto dos outros, e não em arquivo
    -- separado.
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        -- o projeto é C; sem isso o clangd insere include ao completar símbolo
        "--header-insertion=never",
    },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    -- .clangd primeiro: é o que carrega as flags quando não há
    -- compile_commands.json (caso do dvtm, que usa um .clangd estático).
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "Makefile", ".git" },
})

-- ── Servers habilitados ──────────────────────────────────────────────────────
-- Sem nvim-lspconfig: cada server é self-contained (cmd/filetypes/root_markers
-- definidos aqui; jdtls em jdtls_config.lua). Pra religar os comentados abaixo,
-- defina cmd/filetypes/root_markers deles (ou readicione o nvim-lspconfig).
vim.lsp.enable({
    -- "pyright",
    -- "ts_ls",
    "clangd",
    -- "vimls",
    -- "bashls",
    "texlab",
    "lua_ls",
    "jdtls",
})
