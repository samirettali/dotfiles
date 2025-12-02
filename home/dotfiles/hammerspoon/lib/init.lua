local M = {
	held_keys = {},
	toggle_layout_notification = nil,
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

return M
