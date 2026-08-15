local applications = require("applications")
local lib = require("lib")

hs.hotkey.bind({ "alt" }, "space", applications.show)
hs.hotkey.bind({ "alt", "shift" }, "R", hs.reload)

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
hs.hotkey.bind({ "cmd", "ctrl" }, "l", lib.toggleLayout)

hs.hotkey.bind({ "alt" }, "delete", hs.spotify.playpause)
hs.hotkey.bind({ "alt" }, "[", hs.spotify.previous)
hs.hotkey.bind({ "alt" }, "]", hs.spotify.next)
hs.hotkey.bind({ "alt", "shift" }, "[", hs.spotify.rw, nil, hs.spotify.rw)
hs.hotkey.bind({ "alt", "shift" }, "]", hs.spotify.ff, nil, hs.spotify.ff)

-- Basic window handling for machines without a window manager — a work laptop
-- where a colleague may need to sit down, or this one if aerospace ever goes.
-- Deliberately nothing that fights macOS's own window behaviour.
local hasFeatures, features = pcall(require, "features")

if not (hasFeatures and features.aerospace) then
	hs.hotkey.bind({ "alt", "shift" }, "h", lib.tile_left)
	hs.hotkey.bind({ "alt", "shift" }, "l", lib.tile_right)
	hs.hotkey.bind({ "alt", "shift" }, ",", lib.send_to_prev_screen)
	hs.hotkey.bind({ "alt", "shift" }, ".", lib.send_to_next_screen)

	hs.hotkey.bind({ "alt" }, ",", lib.focus_prev_screen)
	hs.hotkey.bind({ "alt" }, ".", lib.focus_next_screen)
end

-- hack to disable cmd+m
local function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)
hs.hotkey.bind({ "cmd" }, "h", noop)
hs.hotkey.bind({ "cmd", "alt" }, "h", noop)
