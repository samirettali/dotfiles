local M = {
	held_keys = {},
	toggle_layout_notification = nil,
	ignored_windows = {
		choose = true,
	},
	floating_windows = {
		Finder = true,
		["System Settings"] = true,
		choose = true,
	},
	is_keyboard_disabled = false,
}

M.is_empty = function(s)
	return s == nil or s == ""
end

M.is_empty_or_whitespace = function(s)
	return M.is_empty(s) or s:match("^%s*$") ~= nil
end

M.file_exists = function(file)
	local f = io.open(file, "rb")
	if f ~= nil then
		f:close()
	end

	return f ~= nil
end

M.merge_tables = function(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				M.merge_tables(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end

	return t1
end

M.toggle_play_pause = function()
	hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
	hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

M.next_track = function()
	hs.eventtap.event.newSystemKeyEvent("NEXT", true):post()
	hs.eventtap.event.newSystemKeyEvent("NEXT", false):post()
end

M.previous_track = function()
	hs.eventtap.event.newSystemKeyEvent("PREVIOUS", true):post()
	hs.eventtap.event.newSystemKeyEvent("PREVIOUS", false):post()
end

M.rbind = function(modifier, key, callback, interval)
	interval = interval or 0.05

	cb = function()
		if M.held_keys[key] then
			callback()
			hs.timer.doAfter(interval, cb)
		end
	end

	local combination = {
		modifier,
		key,
	}

	local pressedfn = function()
		M.held_keys[combination] = true
		cb()
	end

	local releasedfn = function()
		M.held_keys[combination] = false
		cb()
	end

	hs.hotkey.bind(modifier, key, pressedfn, releasedfn)
end

M.toggleLayout = function()
	local layouts = hs.keycodes.layouts()

	local currentLayout = hs.keycodes.currentLayout()

	local idx = nil
	for i, layout in ipairs(layouts) do
		if layout == currentLayout then
			idx = i
			break
		end
	end

	if idx == nil then
		hs.alert.show("Could not find current layout in list")
		return
	end

	idx = idx + 1

	if idx > #layouts then
		idx = 1
	end

	local nextLayout = layouts[idx]

	local changed = hs.keycodes.setLayout(nextLayout)

	if M.toggle_layout_notification ~= nil then
		hs.alert.closeSpecific(M.toggle_layout_notification)
	end

	if not changed then
		M.toggle_layout_notification = hs.alert.show("Keyboard: " .. nextLayout, 1)
		return
	end

	M.toggle_layout_notification = hs.alert.show("Keyboard: " .. nextLayout, 1)
end

M.handle_window = function(win, app_name, event)
	if not win then
		return
	end

	if M.ignored_windows[app_name] then
		return
	end

	M.log.f(
		"handling window event: app_name: %s, event: %s, isStandard: %s, role: %s, subrole: %s, title: %s",
		app_name,
		event,
		tostring(win:isStandard()),
		win:role(),
		win:subrole(),
		win:title()
	)

	if M.floating_windows[app_name] and win:isStandard() then
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

M.send_to_prev_screen = function()
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
end

M.send_to_next_screen = function()
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
end

M.tile_right = function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	local half = math.floor(max.w / 2)
	local third = math.floor(max.w / 3)
	local two_thirds = math.floor(max.w * 2 / 3)

	local new_w
	if math.abs(f.w - half) < 2 then
		new_w = third
	elseif math.abs(f.w - third) < 2 then
		new_w = two_thirds
	else
		new_w = half
	end

	f.x = max.x
	f.y = max.y
	f.w = new_w
	f.h = max.h
	win:setFrame(f)
end

M.tile_left = function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	local half = math.floor(max.w / 2)
	local third = math.floor(max.w / 3)
	local two_thirds = math.floor(max.w * 2 / 3)

	local new_w
	if math.abs(f.w - half) < 2 then
		new_w = third
	elseif math.abs(f.w - third) < 2 then
		new_w = two_thirds
	else
		new_w = half
	end

	f.x = max.x + (max.w - new_w)
	f.y = max.y
	f.w = new_w
	f.h = max.h
	win:setFrame(f)
end

M.focus_prev_screen = function()
	local currentScreen = hs.screen.mainScreen()
	local prevScreen = currentScreen:previous()
	local windows = hs.window.orderedWindows()
	for _, win in ipairs(windows) do
		if win:screen() == prevScreen then
			win:focus()
			break
		end
	end
end

M.focus_next_screen = function()
	local currentScreen = hs.screen.mainScreen()
	local nextScreen = currentScreen:next()
	local windows = hs.window.orderedWindows()
	for _, win in ipairs(windows) do
		if win:screen() == nextScreen then
			win:focus()
			break
		end
	end
end

M.log = hs.logger.new("lib", "debug")

return M
