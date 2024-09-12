local M = {}

function M.reveal()
    local current_dir = vim.fn.expand('%:p:h')
    local current_file = vim.fn.expand("%:t")

    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port .. " && "
    local terminal_command = nvim_socket .. os.getenv('NVIM_TERM_CMD')
    local command = 'lf ' .. (current_file:find('^.') ~= nil and '--command \'set hidden\' ' or '') .. vim.fn.expand('%:p')
    local full_command = terminal_command .. ' ' .. command .. ' 2>/dev/null 1>/dev/null &'

    os.execute(full_command)
end 

return M
