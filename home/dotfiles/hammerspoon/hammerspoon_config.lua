local lib = require("lib")

local alertStyle = {
	strokeWidth = 4,
	strokeColor = { white = 0.9, alpha = 0.9 },
	fillColor = { white = 0, alpha = 1 },
	textColor = { white = 0.9 },
	textFont = "JetBrainsMono Nerd Font",
	textSize = 20,
	padding = 20,
	radius = 24,
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

hs.alert.defaultStyle = lib.merge_tables(hs.alert.defaultStyle, alertStyle)

hs.window.animationDuration = 0
