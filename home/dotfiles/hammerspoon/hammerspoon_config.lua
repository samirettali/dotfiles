local canvas = require("canvas")

-- canvas.lua draws every panel from this: chrome() halves strokeWidth and insets
-- what is left, so a width of 2 lands as the 1pt hairline that frames a panel
-- without competing with the text inside it
local defaultStyle = {
	strokeWidth = 6,
	strokeColor = { white = 1, alpha = 0.4 },
	fillColor = { white = 0, alpha = 1 },
	textColor = { white = 1, alpha = 1 },
	textFont = "JetBrainsMono Nerd Font",
	textSize = 19,
	radius = 12,
	atScreenEdge = 0,
	fadeInDuration = 0.0,
	fadeOutDuration = 0.0,
	padding = 18,
}

hs.alert.defaultStyle = defaultStyle

-- hs.alert draws its own chrome, with the stroke centred on the panel edge and
-- the outer half clipped: on the corner arc that clip cuts diagonally and the
-- curve comes out soft. Send every alert through canvas.toast() instead, so the
-- toasts match the launcher and the pickers rather than sitting a notch below
-- them. Overriding show() keeps the two dozen hs.alert.show calls as they are.
local ALERT_SECONDS = 2

-- hs.alert.show(str[, style][, screen][, seconds]) sorts its arguments by type,
-- and takes true in place of a duration to hold the alert until it is closed
hs.alert.show = function(message, ...)
	local seconds = ALERT_SECONDS

	for i = 1, select("#", ...) do
		local argument = select(i, ...)

		if type(argument) == "number" then
			seconds = argument
		elseif argument == true then
			seconds = nil
		end
	end

	return canvas.toast(message, seconds)
end

hs.alert.closeSpecific = function(id)
	canvas.closeToast(id)
end

hs.alert.closeAll = function()
	canvas.closeToasts()
end

hs.window.animationDuration = 0
