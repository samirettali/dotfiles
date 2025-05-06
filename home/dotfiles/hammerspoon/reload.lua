function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

hs.notify.new({ title = "Hammerspoon", informativeText = "Configuration loaded" }):send()

hs.hotkey.bind({ "alt", "shift" }, "R", hs.reload)
