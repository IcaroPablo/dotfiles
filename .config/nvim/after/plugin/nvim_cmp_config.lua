-- verificar instalação

local cmp = require('cmp')
-- local lspkind = require 'lspkind'

cmp.setup({
--   formatting = {
--     format = lspkind.cmp_format({
--       mode = 'symbol',       -- show only symbol annotations
--       maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
--       ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

--       -- The function below will be called before any actual modifications from lspkind
--       -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
--       before = function(entry, vim_item)
--         return vim_item
--       end
--     })
--   }
-- })
    sources = cmp.config.sources({
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
        {name = 'luasnip'},
        -- {name = 'vsnip'},
        {name = 'buffer'},
        {
            name = 'path',
            option = {
                get_cwd = function()
                    return vim.fn.getcwd()
                end
            }
        }
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
        -- because we are using the vsnip cmp plugin
        -- expand = function(args)
        --     vim.fn['vsnip#anonymous'](args.body)
        -- end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        -- ['<CR>'] = cmp.mapping.confirm({
        --     behavior = cmp.ConfirmBehavior.Replace,
        --     select = true
        -- }),
        ['<Tab>'] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    fallback()
                end
            end,
            {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end,
            {'i', 's'})
    })
})

-- File types specifics
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({{ name = 'cmp_git' }}, {{ name = 'buffer' }})
})

-- Command line completion
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{name = 'buffer'}}
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}})
})
