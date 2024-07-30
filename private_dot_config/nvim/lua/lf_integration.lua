local lf_integration = {}

function lf_integration.open_new_lf()
    os.execute("export NVIM_SOCKET=" .. vim.g.current_port .. " ; " .. os.getenv('NVIM_TERMINAL') .. ' -e lf &')
    os.execute('sleep 0.10')

    local handle = io.popen('cat /tmp/lf_server_id')
    local output = handle:read('*a')

    vim.g.lf_server = output:gsub('[\n\r]', ' ')

    handle:close()
end

function lf_integration.reveal()
    local current_dir = vim.fn.getcwd()
    local current_file = vim.fn.expand("%")

    local cd_command = "lf -remote \"send " .. vim.g.lf_server .. "cd \"" .. current_dir .. "\"\" 2>&1 | grep -q . && exit 0 || exit 1"
    local select_command = "lf -remote \"send " .. vim.g.lf_server .. "select \"" .. current_file .. "\"\" 2>&1 | grep -q . && exit 0 || exit 1"

    local cd_result = os.execute(cd_command)
    local select_result = os.execute(select_command)

    return {cd_result = cd_result, select_result = select_result}
end

function lf_integration.reveal_in_lf()
    if vim.g.lf_server == nil then
        lf_integration.open_new_lf()
    end

    local result = lf_integration.reveal()

    if result.cd_result == 0 or result.select_result == 0 then
        lf_integration.open_new_lf()
        lf_integration.reveal()
    end
end

return lf_integration
