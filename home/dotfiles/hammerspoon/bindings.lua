local lib = require("lib")
local spotify = require("spotify")

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
hs.hotkey.bind({ "cmd", "ctrl" }, "l", lib.toggleLayout)

hs.hotkey.bind({ "alt" }, "delete", spotify.play_pause)
hs.hotkey.bind({ "alt" }, "[", spotify.prev)
hs.hotkey.bind({ "alt" }, "]", spotify.next)
hs.hotkey.bind({ "alt", "shift" }, "[", spotify.rw, nil, spotify.rw)
hs.hotkey.bind({ "alt", "shift" }, "]", spotify.ff, nil, spotify.ff)
