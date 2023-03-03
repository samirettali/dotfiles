local wezterm = require("wezterm")

local M = {}

M.color_scheme = "Builtin Dark"
M.font_size = 16
M.adjust_window_size_when_changing_font_size = false

M.enable_tab_bar = false

M.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

M.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Medium", italic = false })

M.bold_brightens_ansi_colors = true

M.exit_behavior = "Close"

return M
