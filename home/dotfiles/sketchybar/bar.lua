local colors = require("colors")

sbar.bar({
	height = 32,
	notch_display_height = 40,
	color = colors.black,
	padding_right = 5,
	padding_left = 5,
	font_smoothing = true,
	shadow = true,
})

local font = "JetBrainsMonoNL Nerd Font"
local style = "Regular"

sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = "JetBrainsMono Nerd Font",
			style = style,
			size = 14,
		},
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	label = {
		font = {
			family = font,
			style = style,
			size = 14,
		},
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	padding_left = 4,
	padding_right = 4,
})
