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

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                -- procura no runtimepath inteiro, não em get_installed(): este
                -- só enxerga o diretório do plugin, então os parsers que o
                -- neovim embute apareceriam como ausentes e seriam rebaixados
                local tem = lang and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0
                if lang and not tem and vim.tbl_contains(ts.get_available(), lang) then
                    ts.install(lang) -- assíncrono: pega no próximo buffer do tipo
                end
                pcall(vim.treesitter.start, args.buf) -- sem parser, cai no syntax do vim
            end,
        })
    end,
}
