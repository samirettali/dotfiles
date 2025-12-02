local lib = require("lib")

hs.hotkey.bind({ "cmd", "shift" }, "l", hs.caffeinate.startScreensaver)
hs.hotkey.bind({ "cmd", "ctrl" }, "l", lib.toggleLayout)
