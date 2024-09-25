
-- ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║╚════██║
-- ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝███████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

local mappings = {}

local nore_silent = { noremap = true, silent = true };

----------------------
-- GENERAL MAPPINGS --
----------------------

function mappings.setup_basic_mappings()

    -- easily manage tabs
    vim.keymap.set("n", "<leader>n", ":tabnew<CR>", nore_silent)
    vim.keymap.set("n", "<Right>", ":tabnext<CR>", nore_silent)
    vim.keymap.set("n", "<Left>", ":tabprev<CR>", nore_silent)
    vim.keymap.set("n", "<leader>bt", ":tab sball<CR>", nore_silent)
    vim.keymap.set("n", "<leader>c", ":tabclose<CR>", nore_silent)
    vim.keymap.set("n", "<leader>C", ":tabonly<CR>", nore_silent)

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

    -- utils
    vim.keymap.set("n", "TT", function() require('utils').open_terminal_in(vim.fn.expand('%:p:h')) end, { noremap = true, silent = true })
    vim.keymap.set("n", "tt", require('utils').open_terminal_in_project_root, { noremap = true, silent = true })
    vim.keymap.set("n", "<C-f>", require('lf_integration').reveal, {noremap = true, silent = true})

    -- navigate quickfixes
    vim.keymap.set("n", "<c-p>", ":cprev<CR>zz", { noremap = true, silent = true })
    vim.keymap.set("n", "<c-n>", ":cnext<CR>zz", { noremap = true, silent = true })

    -- center search results
    -- vim.keymap.set("n", "n", "nzz", {noremap = true, silent = true})
    -- vim.keymap.set("n", "N", "Nzz", {noremap = true, silent = true})
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    -- vim.keymap.set("n", "#", "#zz", { silent = true, noremap = true })
    -- vim.keymap.set("n", "g*", "g*zz", { silent = true, noremap = true })
    -- vim.keymap.set("n", "g#", "g#zz", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader>w", "*N", { silent = true, noremap = true })
    vim.keymap.set("x", "<leader>p", [["_dP]])
    vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

    -- deactivate space because of annoying behaviour since its my leader key :)
    vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true})

    -- word substitution
    -- vim.keymap.set("n", "<C-j>", "ciw<C-r>0<ESC>", {silent = true})
    vim.keymap.set("n", "<C-s>", "\"1yiwciw<C-r>0<ESC>/<C-r>1<CR>", {silent = true})
    vim.keymap.set("n", "<Leader>jq", ":%!jq '.'<CR>", {silent = true})

    -- other niceties
    vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
    vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
    vim.keymap.set("n", "<Leader><Leader>", ":write<CR>", {noremap = true, silent = true})
    vim.keymap.set("n", "<c-[>", "<esc>:nohlsearch<CR>", {silent = true})

end

----------------------
-- PLUGINS MAPPINGS --
----------------------

-- map("n", "<leader>gl", "<cmd>Gitsigns toggle_signs<CR>", { silent = true, noremap = true })
-- map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { silent = true, noremap = true })
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

function mappings.setup_nvim_lsp_on_attach(bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- diagnostics
    vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, nore_silent)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({count = -1}) end, nore_silent)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({count = 1}) end, nore_silent)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<Leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set({"n", 'v'}, "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<Leader>cf", function() vim.lsp.buf.format({async = true}) end, bufopts)
end

function mappings.setup_jdtls(bufnr)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<leader>jdi", require('jdtls').organize_imports, bufopts)
    vim.keymap.set("n", "<leader>jev", require('jdtls').extract_variable, bufopts)
    vim.keymap.set("v", "<leader>jev", function() require('jdtls').extract_variable({true, 'variable'}) end, bufopts)
    vim.keymap.set('v', '<Leader>jec', function() require('jdtls').extract_constant({true, 'constant'}) end, bufopts)
    vim.keymap.set("v", "<leader>jem", function() require('jdtls').extract_method({true, function() return 'extracted' end}) end, bufopts)

    -- for tests (ver quais outras funções estão disponíveis também)
    vim.keymap.set("n", "<leader>jtc", require('jdtls').test_class, bufopts)
    vim.keymap.set("n", "<leader>jtm", require('jdtls').test_nearest_method, bufopts)
    -- require("jdtls.tests").generate()
    -- require("jdtls.tests").goto_subjects()

end

function mappings.setup_nvim_dap(bufnr)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<Leader>jtb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", bufopts)
    vim.keymap.set("n", "<Leader>jsb", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", "Set log point")
    -- vim.keymap.set("n", '<Leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>", "Clear breakpoints")
    -- vim.keymap.set("n", '<Leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "List breakpoints")

    vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<cr>", bufopts)
    -- vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<cr>", "Step over")
    -- vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_into()<cr>", "Step into")
    -- vim.keymap.set("n", "<Leader>do", "<cmd>lua require'dap'.step_out()<cr>", "Step out")
    -- vim.keymap.set("n", '<Leader>dd', "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect")
    vim.keymap.set("n", '<Leader>dt', "<cmd>lua require'dap'.terminate()<cr>", bufopts)
    vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", bufopts)
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

function mappings.setup_telescope()

    -- map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>gb", "<cmd>Telescope git_bcommits<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader><Tab>", require('telescope.builtin').buffers, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files({hidden = true, cwd = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})}) end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gf', function() require('telescope.builtin').git_files({hidden = true, cwd = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})}) end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>lg', function() require('telescope.builtin').live_grep({hidden = true, cwd = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})}) end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>d', function() require('telescope.builtin').diagnostics({ severity_bound = 0 }) end, { noremap = true, silent = true })
    -- nnoremap("<leader>fm", "<cmd>Telescope marks<cr>", "Find mark")
    -- nnoremap("<leader>fr", "<cmd>Telescope lsp_references<cr>", "Find references (LSP)")
    -- nnoremap("<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", "Find symbols (LSP)")
    -- nnoremap("<leader>fc", "<cmd>Telescope lsp_incoming_calls<cr>", "Find incoming calls (LSP)")
    -- nnoremap("<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>", "Find outgoing calls (LSP)")
    -- nnoremap("<leader>fi", "<cmd>Telescope lsp_implementations<cr>", "Find implementations (LSP)")
    -- nnoremap("<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>", "Find errors (LSP)")
    -- map("n", "<leader>h", "<cmd>Telescope oldfiles<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>j", "<cmd>Telescope resume<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>k", "<cmd>Telescope zoxide list<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>m", "<cmd>Telescope man_pages<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>n", "<cmd>Telescope builtin<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>qc", "<cmd>Telescope lsp_code_actions<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>sf", "<cmd>Telescope spell_suggests<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>t", ":lua require('telescope').extensions.dict.synonyms()<CR>", { silent = true, noremap = true })
    -- map("n", "<leader>;", "<cmd>Telescope keymaps<CR>", { silent = true, noremap = true })
end

return mappings
