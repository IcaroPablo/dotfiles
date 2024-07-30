local utils = {}

function utils.open_terminal_in_current_folder()
    local cwd = vim.loop.cwd()
    local home = os.getenv('HOME')
    local split_script = home .. '/Workspace/shell-script-collection/split_script.sh'
    local fifo_file = home .. '/Workspace/shell-script-collection/dvtm_fifo.file'

    -- local lel = 'echo create ' .. split_script.. ' ' .. cwd .. ' > ' .. fifo_file .. ' &'
    -- print(lel)
    os.execute('echo ' .. cwd .. ' > ~/cwd.txt')
    -- os.execute('echo create ' .. split_script.. ' ' .. cwd .. ' > ' .. fifo_file .. ' &')
    os.execute('echo create ' .. split_script .. ' > ' .. fifo_file .. ' &')
    -- os.execute('echo create ~/pou.sh ' .. cwd .. ' > ~/fifo.file &')
end

return utils
