require('vis')

-- optional until vis-fzf-open is back in the repo: it's an empty gitlink for now
pcall(require, 'vis-fzf-open')

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
	vis:command('set expandtab on')
	vis:command('set tabwidth 4')
end)

vis:command_register('xsp', function(argv)
	local file = vis.win.file
	local path = argv[1] or file.path
	if not os.getenv("DISPLAY") then
		vis:info("Error: $DISPLAY doesn't exist")
		return
	end
	local cmd = string.format('st -e vise "%s" &', path)
	os.execute(cmd)
end, "Open file in a new X11 window")
