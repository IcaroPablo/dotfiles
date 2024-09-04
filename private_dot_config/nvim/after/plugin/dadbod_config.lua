-- dealing with database connections
vim.cmd [[
    function! ConnectToDatabase()
        let filename = expand('%:p')
        let command = "grep -m 1 'db' " . filename . " | awk -F '=' '{print $2}' | awk '{$1=$1};1'"
        let dbalias = system(command)
        let credscommand = "creds -s " . dbalias
        let creds = system(credscommand)
        execute "DB t:db = " . creds
        echo "connected to " . dbalias
    endfunction
]]

-- TODO: função de <leader>r melhorada para ler as variáveis

-- run selected query
vim.keymap.set("n", "<Leader>r", "vip:DB<CR>", {silent = true, noremap = true})
-- connect to DB
vim.keymap.set("n", "<Leader>db", ":call ConnectToDatabase()<CR>", {silent = true, noremap = true})
