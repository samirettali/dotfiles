-- the stroke is centred on the panel edge, so half of it is clipped away and a
-- width of 2 draws a 1pt hairline: a quiet border that frames the panel instead
-- of competing with the text inside it
local defaultStyle = {
	strokeWidth = 2,
	strokeColor = { white = 1, alpha = 0.4 },
	fillColor = { white = 0, alpha = 1 },
	textColor = { white = 1, alpha = 1 },
	textFont = "JetBrainsMono Nerd Font",
	textSize = 19,
	radius = 12,
	atScreenEdge = 0,
	fadeInDuration = 0.0,
	fadeOutDuration = 0.0,
	padding = 22,
}

hs.alert.defaultStyle = defaultStyle

hs.window.animationDuration = 0
