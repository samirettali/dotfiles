local lib = require("lib")

hs.hotkey.bind({ "alt" }, "[", lib.previous_track)
hs.hotkey.bind({ "alt" }, "]", lib.next_track)
hs.hotkey.bind({ "alt" }, "delete", lib.toggle_play_pause)

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
