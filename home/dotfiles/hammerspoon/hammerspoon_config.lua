local lib = require("lib")

local alertStyle = {
	strokeWidth = 8,
	strokeColor = { white = 1, alpha = 1 },
	fillColor = { white = 0, alpha = 1 },
	textColor = { white = 1, alpha = 1 },
	textFont = "JetBrainsMono Nerd Font",
	textSize = 20,
	padding = 30,
	radius = 16,
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

hs.alert.defaultStyle = lib.merge_tables(hs.alert.defaultStyle, alertStyle)

hs.window.animationDuration = 0
