local wezterm = require("wezterm")

return {
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" }),
	font_size = 12.5,
	enable_tab_bar = false,
	color_scheme = "Builtin Dark",
	adjust_window_size_when_changing_font_size = false,
	enable_wayland = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
