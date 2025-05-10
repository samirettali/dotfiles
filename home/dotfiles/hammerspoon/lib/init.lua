local M = {}

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

return M
