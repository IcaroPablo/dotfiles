local Path = require('plenary.path')

local config = require('session_manager.config').defaults

config.dir_to_session_filename = function()
    local path_replacer = '__'
    local colon_replacer = '++'
    local root_folder = require('utils').get_root() or vim.uv.cwd()

    local filename = root_folder:gsub(':', colon_replacer)

    filename = filename:gsub(Path.path.sep, path_replacer)

    return Path:new(config.sessions_dir):joinpath(filename)
end

config.autoload_mode = require('session_manager.config').AutoloadMode.Disabled

require('session_manager').setup(config)

local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands

-- move to root folder after loading a session
vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = "SessionLoadPost",
    group = config_group,
    callback = function()
        vim.cmd('cd ' .. (require('utils').get_root() or vim.uv.cwd()))
    end
})
