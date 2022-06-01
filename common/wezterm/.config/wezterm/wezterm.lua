local wezterm = require("wezterm")

local M = {}

M.color_scheme = "Builtin Dark"
M.font_size = 13

M.freetype_load_flags = "NO_HINTING"
M.freetype_load_target = "Normal"

M.enable_tab_bar = false

M.window_decorations = "NONE"
M.window_close_confirmation = "NeverPrompt"
M.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

M.font_rules = { {
    italic = false,
    intensity = "Normal", -- Bold | Normal | Half
    underline = "None",
    blink = "None",
    font = wezterm.font("JetBrainsMono Nerd Font", {
        bold = false,
        italic = false,
        weight = "Medium"
    }),
} }

return M
