local lib = require("lib")

hs.hotkey.bind({ "alt", "shift" }, "R", hs.reload)

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
hs.hotkey.bind({ "cmd", "ctrl" }, "l", lib.toggleLayout)

hs.hotkey.bind({ "alt" }, "delete", hs.spotify.playpause)
hs.hotkey.bind({ "alt" }, "[", hs.spotify.previous)
hs.hotkey.bind({ "alt" }, "]", hs.spotify.next)
hs.hotkey.bind({ "alt", "shift" }, "[", hs.spotify.rw, nil, hs.spotify.rw)
hs.hotkey.bind({ "alt", "shift" }, "]", hs.spotify.ff, nil, hs.spotify.ff)

-- Set up a window filter to watch for new windows
-- The 'default' filter automatically ignores invisible windows, popups, and background apps
hs.window.filter.new(true):subscribe(hs.window.filter.windowCreated, lib.handle_window)

hs.hotkey.bind({ "alt" }, "m", function()
	local win = hs.window.focusedWindow()
	lib.handle_window(win, win:application():name())
end)

hs.hotkey.bind({ "alt", "shift" }, "m", function()
	local wins = hs.window.allWindows()
	for _, win in ipairs(wins) do
		lib.handle_window(win, win:application():name())
	end
end)

hs.hotkey.bind({ "alt", "shift" }, "h", lib.tile_right)
hs.hotkey.bind({ "alt", "shift" }, "l", lib.tile_left)
hs.hotkey.bind({ "alt", "shift" }, ",", lib.send_to_prev_screen)
hs.hotkey.bind({ "alt", "shift" }, ".", lib.send_to_next_screen)

hs.hotkey.bind({ "alt" }, ".", lib.focus_next_screen)
hs.hotkey.bind({ "alt" }, ",", lib.focus_prev_screen)

-- hack to disable cmd+m
local function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)
hs.hotkey.bind({ "cmd" }, "h", noop)
hs.hotkey.bind({ "cmd", "alt" }, "h", noop)
