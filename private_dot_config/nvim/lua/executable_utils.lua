local utils = {}

function utils.run(command)
    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port
    local terminal_command = nvim_socket  .. " ; " .. os.getenv('NVIM_TERMINAL') .. ' -e '
    local full_command = terminal_command .. command .. ' 2>/dev/null 1>/dev/null &'

    os.execute(full_command)
    -- os.execute("export NVIM_SOCKET=" .. vim.g.current_port .. " ; " .. os.getenv('NVIM_TERMINAL') .. ' -e lf &')
end

function utils.open_terminal_in_current_folder()
    -- local cwd = vim.loop.cwd()
    -- local home = os.getenv('HOME')
    -- local split_script = home .. '/Workspace/shell-script-collection/split_script.sh'
    -- local fifo_file = home .. '/Workspace/shell-script-collection/dvtm_fifo.file'

    -- -- local lel = 'echo create ' .. split_script.. ' ' .. cwd .. ' > ' .. fifo_file .. ' &'
    -- -- print(lel)
    -- os.execute('echo ' .. cwd .. ' > ~/cwd.txt')
    -- -- os.execute('echo create ' .. split_script.. ' ' .. cwd .. ' > ' .. fifo_file .. ' &')
    -- os.execute('echo create ' .. split_script .. ' > ' .. fifo_file .. ' &')
    -- -- os.execute('echo create ~/pou.sh ' .. cwd .. ' > ~/fifo.file &')

    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port
    local initial_folder = "export INITIAL_FOLDER=" .. vim.fn.expand('%:h')
    local terminal_command = nvim_socket  .. " ; " .. initial_folder .. " ; " .. os.getenv('NVIM_TERMINAL')
    local full_command = terminal_command .. ' 2>/dev/null &'

    os.execute(full_command)
end

function utils.open_terminal_in_project_root()
    local nvim_socket = "export NVIM_SOCKET=" .. vim.g.current_port
    local project_folder = vim.fs.root(0, {".git", "mvnw", "gradlew", "pom.xml"})
    local initial_folder = "export INITIAL_FOLDER=" .. (project_folder ~= nil and project_folder or vim.fn.expand('%:h'))
    local terminal_command = nvim_socket  .. " ; " .. initial_folder .. " ; " .. os.getenv('NVIM_TERMINAL')
    local full_command = terminal_command .. ' 2>/dev/null &'

    os.execute(full_command)
end

return utils
