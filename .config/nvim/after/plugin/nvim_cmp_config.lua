local cmp = require('cmp')

-- local has_any_words_before = function()
-- 	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
-- 		return false
-- 	end
-- 	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
-- 	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

-- local press = function(key)
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", true)
-- end

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
		-- {name = "ultisnips"},
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
        ['<CR>'] = cmp.mapping(
            function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    fallback()
                end
            end,
            {'i', 's'}),
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
		--       ["<C-i>"] = function(fallback)
		-- 	if vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
		-- 		press("<ESC>:call UltiSnips#JumpForwards()<CR>")
		-- 	elseif cmp.visible() then
		-- 		cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
		-- 	elseif has_any_words_before() then
		-- 		press("<Space>")
		-- 	else
		-- 		fallback()
		-- 	end
		-- end,
		-- ["<Tab>"] = function(fallback)
		-- 		if vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
		-- 			press("<ESC>:call UltiSnips#JumpForwards()<CR>")
		-- 		elseif cmp.visible() then
		-- 			cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
		-- 		elseif has_any_words_before() then
		-- 			press("<Tab>")
		-- 		else
		-- 			fallback()
		-- 		end
		-- 	end,
		-- ["<S-Tab>"] = function(fallback)
		-- 		if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
		-- 			press("<ESC>:call UltiSnips#JumpBackwards()<CR>")
		-- 		elseif cmp.visible() then
		-- 			cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
		-- 		else
		-- 			fallback()
		-- 		end
		-- 	end
    }),
	-- window = {
	-- 	documentation = {
	-- 		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
	-- 		winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
	-- 		max_width = 120,
	-- 		max_height = math.floor(vim.o.lines * 0.3),
	-- 	},
	-- },
	-- enabled = function()
	-- 	return vim.g.cmp_toggle
	-- end,
	-- snippet = {
	-- 	expand = function(args)
	-- 		vim.fn["UltiSnips#Anon"](args.body)
	-- 	end,
	-- },
	-- completion = {
	-- 	completeopt = "menu,menuone,noinsert",
	-- },
	-- cmp.setup.filetype({ "markdown" }, {
	-- 	sources = {
	-- 		{ name = "path" },
	-- 		{ name = "ultisnips" },
	-- 		{ name = "nvim_lsp" },
	-- 		{
	-- 			name = "buffer",
	-- 			options = {
	-- 				get_bufnrs = function()
	-- 					local bufs = {}
	-- 					for _, win in ipairs(vim.api.nvim_list_wins()) do
	-- 						bufs[vim.api.nvim_win_get_buf(win)] = true
	-- 					end
	-- 					return vim.tbl_keys(bufs)
	-- 				end,
	-- 			},
	-- 		},
	-- 	},
	-- }),
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
