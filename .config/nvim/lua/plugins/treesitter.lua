-- Branch main (exige neovim 0.12 e tree-sitter-cli): o plugin virou só
-- instalador de parser e query. O highlight é do neovim e se liga no autocmd
-- abaixo — o main não tem módulos nem auto_install, isso é por nossa conta.
local LANGS = { "bash", "java", "json", "sql" }

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- o plugin não suporta lazy-loading
    -- o build é string e não função: o lazy carrega o plugin antes de executar
    -- um comando, mas numa build-função o diretório ainda não está no
    -- runtimepath (medido: rtp_matches=0) e o require só passa por cache
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")

        -- máquina nova: instala o que falta da lista base
        ts.install(LANGS)

        local tried = {}

        -- procura no runtimepath inteiro, não em get_installed(): este só
        -- enxerga o diretório do plugin, então os parsers que o neovim embute
        -- apareceriam como ausentes e seriam rebaixados
        local function in_rtp(pattern)
            return #vim.api.nvim_get_runtime_file(pattern, false) > 0
        end

        -- get é memoizada e só invalida em OptionSet runtimepath: um install que
        -- linka a query dentro do rtp atual deixa no cache o nil da tentativa
        -- anterior, e o highlight subiria sem query nenhuma
        local function highlights(lang)
            local query = vim.treesitter.query.get(lang, "highlights")
            if not query and in_rtp("queries/" .. lang .. "/highlights.scm") then
                vim.treesitter.query.get:clear()
                query = vim.treesitter.query.get(lang, "highlights")
            end
            return query
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang then
                    return
                end
                -- o parser sozinho não basta: o start desliga o syntax do vim e
                -- sem query o buffer fica sem pintura nenhuma
                if in_rtp("parser/" .. lang .. ".*") and highlights(lang) then
                    pcall(vim.treesitter.start, args.buf)
                elseif not tried[lang] and vim.tbl_contains(ts.get_available(), lang) then
                    -- force: sem ele o install pula quando o .so já existe e um
                    -- link de query quebrado nunca seria refeito
                    tried[lang] = true
                    ts.install(lang, { force = true }) -- assíncrono: pega no próximo buffer do tipo
                end
            end,
        })
    end,
}
