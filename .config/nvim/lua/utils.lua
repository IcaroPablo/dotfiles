local utils = {}

function utils.run(command)
    local current_dir = vim.fn.expand('%:p:h')
    local current_file = vim.fn.expand("%:t")

    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port .. " && "
    local lf_start_dir = 'export LF_START_DIR=' .. current_dir .. ' && '
    local lf_start_select = 'export LF_START_SELECT=' .. current_file .. ' && '
    local terminal_command = nvim_socket .. lf_start_dir .. lf_start_select .. os.getenv('NVIM_TERM_CMD')
    local full_command = terminal_command .. ' ' .. command .. ' 2>/dev/null 1>/dev/null &'

    print(full_command)

    os.execute(full_command)
end

function utils.open_terminal_in(project_folder)
    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port
    local initial_folder_command = "export INITIAL_FOLDER=" .. (project_folder ~= nil and project_folder or vim.fn.expand('%:h'))
    local terminal_command = nvim_socket  .. " ; " .. initial_folder_command .. " ; " .. os.getenv('NVIM_TERMINAL')
    local full_command = terminal_command .. ' 2>/dev/null &'

    os.execute(full_command)
end

function utils.open_terminal_in_project_root()
    local project_folder = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})

    utils.open_terminal_in(project_folder)
end

return utils