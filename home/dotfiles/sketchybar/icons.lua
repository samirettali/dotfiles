-- Ligatures, like `:spotify:`, come from sketchybar-app-font and need
-- `font = icons.app_font` on the item; the rest are Nerd Font glyphs.
local icons = {
	app_font = { family = "sketchybar-app-font" },

	error = ":cancel:",
	spotify = ":spotify:",
	claude = ":claude:",
	mail = "\u{f01ee}",
	gas = ":ethereum:",
	market = ":statistics:",

	herdr = "\u{f0a0b}",

	status = {
		github = ":git_hub:",
		openai = ":openai:",
	},

	volume = {
		_100 = ":volume_high:",
		_66 = ":volume_high:",
		_33 = ":volume_low:",
		_10 = ":volume_low:",
		_0 = ":volume_muted:",
	},
	battery = {
		_100 = "󰁹",
		_75 = "󰂀",
		_50 = "󰁾",
		_25 = "󰁻",
		_0 = "󰂎",
		charging = "󰂄",
	},
	media = {
		play_pause = ":playing:",
		play = ":playing:",
		pause = ":paused:",
	},
}

return icons
