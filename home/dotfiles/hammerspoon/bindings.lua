hs.hotkey.bind({ "alt" }, "[", hs.spotify.previous)
hs.hotkey.bind({ "alt" }, "]", hs.spotify.next)
hs.hotkey.bind({ "alt" }, "delete", hs.spotify.playpause)

hs.hotkey.bind({ "alt", "shift" }, "[", hs.spotify.rw, hs.spotify.rw, hs.spotify.rw)
hs.hotkey.bind({ "alt", "shift" }, "]", hs.spotify.ff, hs.spotify.ff, hs.spotify.ff)

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
