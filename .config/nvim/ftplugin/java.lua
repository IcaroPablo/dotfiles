-- Keymaps específicos de Java. O LSP (jdtls) é nativo em jdtls_config.lua; os
-- keymaps comuns de LSP (gd, K, gr, <leader>ca/cf, diagnósticos…) vêm do
-- autocmd LspAttach global em after/plugin/nvim_lsp_config.lua.

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

-- refactor do jdtls via code action nativa (kind específico, aplica direto)
local function code_action(kind)
    return function()
        vim.lsp.buf.code_action({ context = { only = { kind } }, apply = true })
    end
end

local opts = { buffer = true, noremap = true, silent = true }

vim.keymap.set("n", "<leader>jtc", function()
    run_maven_test(vim.fn.expand("%:t:r"))
end, opts)
vim.keymap.set("n", "<leader>jtm", function()
    local m = enclosing_method()
    if not m then
        vim.notify("nenhum método de teste sob o cursor", vim.log.levels.WARN)
        return
    end
    run_maven_test(vim.fn.expand("%:t:r") .. "#" .. m)
end, opts)

vim.keymap.set("n", "<leader>jdi", code_action("source.organizeImports"), opts)
vim.keymap.set({ "n", "v" }, "<leader>jev", code_action("refactor.extract.variable"), opts)
vim.keymap.set("v", "<leader>jec", code_action("refactor.extract.constant"), opts)
vim.keymap.set("v", "<leader>jem", code_action("refactor.extract.method"), opts)

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
