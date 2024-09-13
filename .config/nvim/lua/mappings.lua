
-- ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║╚════██║
-- ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝███████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

local mappings = {}

----------------------
-- GENERAL MAPPINGS --
----------------------

function mappings.setup_basic_mappings()

    -- map("n", "[<space>", ":<c-u>put! =repeat(nr2char(10), v:count1)<CR>'[", { silent = true, noremap = true })
    -- map("n", "]<space>", ":<c-u>put =repeat(nr2char(10), v:count1)<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>r", "<cmd>Registers<CR>", { silent = true, noremap = true })
    -- map("n", "<C-P>", ":nohlsearch<CR>:diffupdate<CR>:syntax sync fromstart<CR><c-l>", { silent = true, noremap = true })
    -- map("n", "<leader>w", ":call TrimWhiteSpace()<CR>", { silent = true, noremap = true })

    -- easily manage tabs
    vim.keymap.set("n", "<leader>n", ":tabnew<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<Right>", ":tabnext<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<Left>", ":tabprev<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>bt", ":tab sball<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>c", ":tabclose<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>C", ":tabonly<CR>", { noremap = true, silent = true })

    -- easily manage buffers
    vim.keymap.set("n", "<Tab>", ":bnext<CR>:redraw<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>:redraw<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>q", ":call EasyClose()<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>Q", ":quit!<CR>", { noremap = true, silent = true })
    -- map("n", "<A-<>", "<cmd>BufferMovePrevious<CR>", { silent = true, noremap = true })
    -- map("n", "<A->>", "<cmd>BufferMoveNext<CR>", { silent = true, noremap = true })
    -- map("n", "<A-1>", "<cmd>BufferGoto 1<CR>", { silent = true, noremap = true })
    -- map("n", "<A-2>", "<cmd>BufferGoto 2<CR>", { silent = true, noremap = true })
    -- map("n", "<A-3>", "<cmd>BufferGoto 3<CR>", { silent = true, noremap = true })
    -- map("n", "<A-4>", "<cmd>BufferGoto 4<CR>", { silent = true, noremap = true })
    -- map("n", "<A-5>", "<cmd>BufferGoto 5<CR>", { silent = true, noremap = true })
    -- map("n", "<A-6>", "<cmd>BufferGoto 6<CR>", { silent = true, noremap = true })
    -- map("n", "<A-7>", "<cmd>BufferGoto 7<CR>", { silent = true, noremap = true })
    -- map("n", "<A-8>", "<cmd>BufferGoto 8<CR>", { silent = true, noremap = true })
    -- map("n", "<A-9>", "<cmd>BufferLast<CR>", { silent = true, noremap = true })
    -- map("n", "<A-t>", "<cmd>BufferPin<CR>", { silent = true, noremap = true })
    -- map("n", "<A-c>", "<cmd>BufferClose<CR>", { silent = true, noremap = true })
    -- map("n", "<A-u>", "<cmd>BufferPick<CR>", { silent = true, noremap = true })

    -- easily manage windows
    vim.keymap.set("", "<c-j>", "<c-w>j", { noremap = true, silent = true })
    vim.keymap.set("", "<c-k>", "<c-w>k", { noremap = true, silent = true })
    vim.keymap.set("", "<c-h>", "<c-w>h", { noremap = true, silent = true })
    vim.keymap.set("", "<c-l>", "<c-w>l" ,{ noremap = true, silent = true })

    vim.keymap.set("", "<c-up>", "<c-w>+", { noremap = true, silent = true })
    vim.keymap.set("", "<c-down>", "<c-w>-", { noremap = true, silent = true })
    vim.keymap.set("", "<c-left>", "<c-w>>", { noremap = true, silent = true })
    vim.keymap.set("", "<c-right>", "<c-w><", { noremap = true, silent = true })

    vim.keymap.set("", "<Leader>v", "<c-w>v", { noremap = true, silent = true })
    vim.keymap.set("", "<Leader>s", "<c-w>s", { noremap = true, silent = true })

    -- move lines up and down using alt key
    vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
    vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
    vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true })
    vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true })
    vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
    vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

    -- integrated terminal window
    -- TODO: abrir terminal na pasta atual
    -- vim.keymap.set("n", "tt", require('utils'), { noremap = true, silent = true })
    vim.keymap.set("n", "TT", function() require('utils').open_terminal_in(nil) end, { noremap = true, silent = true })
    vim.keymap.set("n", "tt", require('utils').open_terminal_in_project_root, { noremap = true, silent = true })
    -- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

    -- center search results
    vim.keymap.set("n", "n", "nzz", {noremap = true, silent = true})
    vim.keymap.set("n", "N", "Nzz", {noremap = true, silent = true})
    vim.keymap.set("n", "*", "*zz", { silent = true, noremap = true })
    vim.keymap.set("n", "#", "#zz", { silent = true, noremap = true })
    vim.keymap.set("n", "g*", "g*zz", { silent = true, noremap = true })
    vim.keymap.set("n", "g#", "g#zz", { silent = true, noremap = true })

    -- quick and simple write
    vim.keymap.set("n", "<Leader><Leader>", ":write<CR>", {noremap = true, silent = true})

    -- insert empty lines
    vim.keymap.set("n", "<Leader>o", "o<Esc>k", {noremap = true, silent = true})
    vim.keymap.set("n", "<Leader>O", "O<Esc>j", {noremap = true, silent = true})

    -- deactivate space because of annoying behaviour since its my leader key :)
    vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true})
    -- map("n", "Q", "", { silent = true, noremap = true })
    -- map("n", "gQ", "", { silent = true, noremap = true })

    vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
    vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })

    -- word substitution
    -- vim.keymap.set("n", "<C-j>", "ciw<C-r>0<ESC>", {silent = true})
    vim.keymap.set("n", "<C-s>", "\"1yiwciw<C-r>0<ESC>/<C-r>1<CR>", {silent = true})
    vim.keymap.set("n", "<Leader>jq", ":%!jq '.'<CR>", {silent = true})

    -- TODO: fazer autocommand para verificar bindings

end

----------------------
-- PLUGINS MAPPINGS --
----------------------

-- map("n", "<leader>gl", "<cmd>Gitsigns toggle_signs<CR>", { silent = true, noremap = true })
-- map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { silent = true, noremap = true })
-- map("n", "]p", "<cmd>Gitsigns next_hunk<CR>", { silent = true, noremap = true })
-- map("n", "[p", "<cmd>Gitsigns prev_hunk<CR>", { silent = true, noremap = true })

-- map("n", "<leader>o", "<cmd>SymbolsOutline<CR>", { silent = true, noremap = true })

-- map("n", "<leader>z", "<cmd>ZenMode<CR>", { silent = true, noremap = true })

-- map("n", "<leader>qr", "<cmd>Trouble lsp_references<CR>", { silent = true, noremap = true })
-- map("n", "<leader>qd", "<cmd>Trouble lsp_definitions<CR>", { silent = true, noremap = true })
-- map("n", "<leader>qi", "<cmd>Trouble lsp_implentations<CR>", { silent = true, noremap = true })
-- map("n", "<leader>qt", "<cmd>Trouble lsp_type_definitions<CR>", { silent = true, noremap = true })
-- map("n", "<leader>xx", "<cmd>Trouble<CR>", { silent = true, noremap = true })
-- map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", { silent = true, noremap = true })
-- map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<CR>", { silent = true, noremap = true })
-- map("n", "<leader>xl", "<cmd>Trouble loclist<CR>", { silent = true, noremap = true })
-- map("n", "<leader>xq", "<cmd>Trouble quickfix<CR>", { silent = true, noremap = true })

-- map("n", "<leader>dd", "<cmd>DiffviewOpen<CR>", { silent = true, noremap = true })
-- map("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { silent = true, noremap = true })
-- map("n", "<leader>df", "<cmd>DiffviewFileHistory<CR>", { silent = true, noremap = true })

function mappings.setup_nvim_lsp()
    -- Diagnostics
    vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, {noremap = true, silent = true})
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {noremap = true, silent = true})
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {noremap = true, silent = true})
    -- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, {noremap = true, silent = true})
    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

function mappings.setup_nvim_lsp_on_attach(bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<Leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set({"n", 'v'}, "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    -- vim.keymap.set("n", "<Leader>cf", vim.lsp.buf.format, bufopts)
    vim.keymap.set("n", "<Leader>cf", function() vim.lsp.buf.format({async = true}) end, bufopts)
end

function mappings.setup_jdtls(bufnr)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<leader>jdi", require('jdtls').organize_imports, bufopts)
    vim.keymap.set("n", "<leader>jev", require('jdtls').extract_variable, bufopts)
    vim.keymap.set("v", "<leader>jev", function() require('jdtls').extract_variable({true, 'variable'}) end, bufopts)
    vim.keymap.set('v', '<Leader>jec', function() require('jdtls').extract_constant({true, 'constant'}) end, bufopts)
    vim.keymap.set("v", "<leader>jem", function() require('jdtls').extract_method({true, function() return 'extracted' end}) end, bufopts)

end

function mappings.setup_nvim_dap(bufnr)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- for tests (ver quais outras funções estão disponíveis também)
    -- require("jdtls.tests").generate()
    -- require("jdtls.tests").goto_subjects()
    vim.keymap.set("n", "<leader>jtc", require('jdtls').test_class, bufopts)
    vim.keymap.set("n", "<leader>jtm", require('jdtls').test_nearest_method, bufopts)
    vim.keymap.set("n", "<Leader>jtb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", bufopts)
    vim.keymap.set("n", "<Leader>jsb", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", "Set log point")
    -- vim.keymap.set("n", '<Leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>", "Clear breakpoints")
    -- vim.keymap.set("n", '<Leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "List breakpoints")

    -- vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<cr>", "Continue")
    -- vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<cr>", "Step over")
    -- vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_into()<cr>", "Step into")
    -- vim.keymap.set("n", "<Leader>do", "<cmd>lua require'dap'.step_out()<cr>", "Step out")
    -- vim.keymap.set("n", '<Leader>dd', "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect")
    -- vim.keymap.set("n", '<Leader>dt', "<cmd>lua require'dap'.terminate()<cr>", "Terminate")
    -- vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", "Open REPL")
    -- vim.keymap.set("n", "<Leader>dl", "<cmd>lua require'dap'.run_last()<cr>", "Run last")
    -- vim.keymap.set("n", '<Leader>di', function() require"dap.ui.widgets".hover() end, "Variables")
    -- vim.keymap.set("n", '<Leader>d?', function() local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes) end, "Scopes")
    -- vim.keymap.set("n", '<Leader>df', '<cmd>Telescope dap frames<cr>', "List frames")
    -- vim.keymap.set("n", '<Leader>dh', '<cmd>Telescope dap commands<cr>', "List commands")
    --
    -- map("n", "<leader>er", "<cmd>lua require'dapui'.toggle()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>es", "<cmd>lua require'dap'.continue()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eu", "<cmd>lua require'dap'.step_over()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>ei", "<cmd>lua require'dap'.step_into()<CR>", { silent = true, noremap = true })
    -- map("n", "<F4>", "<cmd>lua require'dap'.step_into()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eo", "<cmd>lua require'dap'.step_out()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>eb", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { silent = true, noremap = true })
    -- map(
    -- 	"n",
    -- 	"<leader>ec",
    -- 	"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    -- 	{ silent = true, noremap = true }
    -- )
    -- map(
    -- 	"n",
    -- 	"<leader>ef",
    -- 	"<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
    -- 	{ silent = true, noremap = true }
    -- )

end

function mappings.setup_vim_commentary()
    vim.keymap.set("n", "<Leader>p", "gcc", { noremap = true, silent = true })
    vim.keymap.set("v", "<Leader>p", "gc", { noremap = true, silent = true })
end


function mappings.setup_neotree()
    vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<C-f>", ":Neotree reveal<CR>", {noremap = true, silent = true})
    vim.keymap.set("n", "<C-f>", require('lf_integration').reveal, {noremap = true, silent = true})
end

function mappings.setup_telescope()

    -- map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>gb", "<cmd>Telescope git_bcommits<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader><Tab>", require('telescope.builtin').buffers, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').find_files({hidden = true, cwd = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})}) end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>g', require('telescope.builtin').live_grep, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>d', function() require('telescope.builtin').diagnostics({ severity_bound = 0 }) end, { noremap = true, silent = true })
    -- nnoremap("<leader>ff", "<cmd>Telescope find_files<cr>", "Find file")
    -- nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>", "Grep")
    -- nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>", "Find buffer")
    -- nnoremap("<leader>fm", "<cmd>Telescope marks<cr>", "Find mark")
    -- nnoremap("<leader>fr", "<cmd>Telescope lsp_references<cr>", "Find references (LSP)")
    -- nnoremap("<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", "Find symbols (LSP)")
    -- nnoremap("<leader>fc", "<cmd>Telescope lsp_incoming_calls<cr>", "Find incoming calls (LSP)")
    -- nnoremap("<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>", "Find outgoing calls (LSP)")
    -- nnoremap("<leader>fi", "<cmd>Telescope lsp_implementations<cr>", "Find implementations (LSP)")
    -- nnoremap("<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>", "Find errors (LSP)")
    -- vim.keymap.set("n", "<leader>s", require('telescope.builtin').grep_string({ search = vim.fn.input('Grep For > ')}), {noremap = true, silent = true})
    -- map("n", "<leader>h", "<cmd>Telescope oldfiles<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>j", "<cmd>Telescope resume<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>k", "<cmd>Telescope zoxide list<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>m", "<cmd>Telescope man_pages<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>n", "<cmd>Telescope builtin<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>qc", "<cmd>Telescope lsp_code_actions<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>sf", "<cmd>Telescope spell_suggests<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>t", ":lua require('telescope').extensions.dict.synonyms()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>y", "<cmd>Telescope file_browser<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>/", "<cmd>Telescope live_grep<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>;", "<cmd>Telescope keymaps<CR>", { silent = true, noremap = true })
end

return mappings
