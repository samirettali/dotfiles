local lib = require("lib")

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
hs.hotkey.bind({ "cmd", "ctrl" }, "l", lib.toggleLayout)

hs.hotkey.bind({ "alt" }, "delete", hs.spotify.playpause)
hs.hotkey.bind({ "alt" }, "[", hs.spotify.previous)
hs.hotkey.bind({ "alt" }, "]", hs.spotify.next)
hs.hotkey.bind({ "alt", "shift" }, "[", hs.spotify.rw, nil, hs.spotify.rw)
hs.hotkey.bind({ "alt", "shift" }, "]", hs.spotify.ff, nil, hs.spotify.ff)
