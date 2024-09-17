local Path = require('plenary.path')

local config = require('session_manager.config').defaults

--- Replaces separators and colons into special symbols to transform session directory into a filename.
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
-- require('session_manager').setup({
  -- sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  -- path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  -- colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
  -- autosave_last_session = true, -- Automatically save last session on exit and on session switch.
  -- autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  -- autosave_ignore_dirs = {}, -- A list of directories where the session will not be autosaved.
  -- autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
  --   'gitcommit',
  -- },
  -- autosave_ignore_buftypes = {}, -- All buffers of these bufer types will be closed before the session is saved.
  -- autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  -- max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
-- })

local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands

-- move to root folder after loading a session
vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = "SessionLoadPost",
    group = config_group,
    callback = function()
        vim.cmd('cd ' .. require('utils').get_root() or vim.uv.cwd())
    end
})
