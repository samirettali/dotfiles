local ignored = {
	choose = true,
}

local floating = {
	Finder = true,
	["System Settings"] = true,
	choose = true,
}

local function handleWindow(win, appName, event)
	if not win then
		return
	end

	if ignored[appName] then
		return
	end

	if floating[appName] and win:isStandard() then
		local screen = win:screen():frame()
		local winFrame = win:frame()

		local x = screen.x + (screen.w - winFrame.w) / 2
		local y = screen.y + (screen.h - winFrame.h) / 2

		win:setFrame(hs.geometry.rect(x, y, winFrame.w, winFrame.h))

		return
	end

	-- Ensure the window still exists and is a standard window (not a dialog or palette)
	if win and win:isStandard() then
		local screen = win:screen()
		local frame = screen:frame()

		win:setFrame(hs.geometry.rect(frame.x, frame.y, frame.w, frame.h))
	end
end

-- Set up a window filter to watch for new windows
-- The 'default' filter automatically ignores invisible windows, popups, and background apps
local autoMaximizeFilter = hs.window.filter.new(true)

autoMaximizeFilter:subscribe(hs.window.filter.windowCreated, function(win, appName, event)
	handleWindow(win, appName, event)
end)

hs.hotkey.bind({ "cmd" }, "m", function()
	local win = hs.window.focusedWindow()
	handleWindow(win, win:application():name())
end)

hs.hotkey.bind({ "cmd", "shift" }, "m", function()
	local wins = hs.window.allWindows()
	for _, win in ipairs(wins) do
		handleWindow(win, win:application():name())
	end
end)

hs.hotkey.bind({ "alt" }, "space", function()
	local windows = hs.window.allWindows()
	local choices = {}

	for _, win in ipairs(windows) do
		local app = win:application()
		local appName = app and app:name() or "Unknown"
		local winTitle = win:title()

		if winTitle and winTitle ~= "" then
			local icon = hs.image.imageFromAppBundle(app:bundleID())
			table.insert(choices, {
				text = hs.styledtext.new(winTitle, { font = { name = "JetBrainsMono Nerd Font" } }),
				subText = hs.styledtext.new(appName, { font = { name = "JetBrainsMono Nerd Font" } }),
				windowId = win:id(),
				image = icon,
			})
		end
	end

	local chooser = hs.chooser.new(function(choice)
		if choice then
			local win = hs.window.get(choice.windowId)
			if win then
				win:focus()
			end
		end
	end)

	chooser:choices(choices)
	chooser:searchSubText(true)
	chooser:show()
end)

hs.hotkey.bind({ "alt", "shift" }, ",", function()
	local win = hs.window.focusedWindow()
	local screens = hs.screen.allScreens()
	local currentScreen = win:screen()
	local currentIndex = nil

	for i, screen in ipairs(screens) do
		if screen == currentScreen then
			currentIndex = i
			break
		end
	end

	local prevIndex = ((currentIndex - 2) % #screens) + 1
	win:moveToScreen(screens[prevIndex])
end)

hs.hotkey.bind({ "alt", "shift" }, ".", function()
	local win = hs.window.focusedWindow()
	local screens = hs.screen.allScreens()
	local currentScreen = win:screen()
	local currentIndex = nil

	for i, screen in ipairs(screens) do
		if screen == currentScreen then
			currentIndex = i
			break
		end
	end

	local nextIndex = (currentIndex % #screens) + 1
	win:moveToScreen(screens[nextIndex])
end)
