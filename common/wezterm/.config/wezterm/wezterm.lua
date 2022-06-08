local wezterm = require("wezterm")

local M = {}

M.color_scheme = "Builtin Dark"
M.font_size = 12
M.adjust_window_size_when_changing_font_size = false

M.freetype_load_flags = "NO_HINTING" -- DEFAULT | NO_HINTING | NO_BITMAP | FORCE_AUTOHINT | MONOCHROME | NO_AUTOHINT
-- M.freetype_load_target = "Normal"

M.enable_tab_bar = false

M.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

local font = wezterm.font("JetBrainsMono Nerd Font")

M.bold_brightens_ansi_colors = true

M.exit_behavior = "Close"

return M
