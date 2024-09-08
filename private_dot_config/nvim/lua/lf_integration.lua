local lf_integration = {}

local utils = require('utils')

function lf_integration.get_server_id()
    local file = io.open('/tmp/lf_server_id', "r")

    if not file then
        return nil
    end

    local content = file:read('*a') -- *a or *all reads the whole file

    file:close()

    if content == '' or tostring(content):find("^%s+$") or content == nil then
        return nil
    else
        return content:gsub('[\n\r]', ' ')
    end
end

function lf_integration.open_new_lf()
    utils.run('lfc')
    os.execute('sleep 0.5')

    return lf_integration.get_server_id()
end

function lf_integration.reveal(server_id)
    local current_dir = vim.fn.expand('%:h')
    local current_file = vim.fn.expand("%")

    -- local cd_command = "lf -remote \"send " .. vim.g.lf_server .. "cd \"" .. current_dir .. "\"\" 2>&1 | grep -q . && exit 0 || exit 1"
    -- local select_command = "lf -remote \"send " .. vim.g.lf_server .. "select \"" .. current_file .. "\"\" 2>&1 | grep -q . && exit 0 || exit 1"

    os.execute('sleep 0.5')

    local cd_command = "lf -remote 'send " .. server_id .. "cd \"" .. current_dir .. "\"'"
    local select_command = "lf -remote 'send " .. server_id .. "select \"" .. current_file .. "\"'"

    os.execute(cd_command .. ' && ' .. select_command)
end

function lf_integration.reveal_in_lf()
    local server_id = lf_integration.get_server_id()

    if server_id == nil then
        server_id = lf_integration.open_new_lf()
    end

    lf_integration.reveal(server_id)
end

return lf_integration
