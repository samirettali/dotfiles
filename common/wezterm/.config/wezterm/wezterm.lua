local wezterm = require("wezterm")

local M = {}

M.color_scheme = "Builtin Dark"
M.font_size = 11.5

M.freetype_load_flags = "NO_HINTING"
-- M.freetype_load_target = "Normal"

M.enable_tab_bar = false

-- M.window_decorations = "NONE"
-- M.window_close_confirmation = "NeverPrompt"
M.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- M.font_rules = {
--     italic = false,
--     intensity = "Normal", -- Bold | Normal | Half
--     underline = "None",
--     blink = "None",
-- }

M.font = wezterm.font("JetBrainsMono Nerd Font Mono", {
    bold = false,
    italic = false,
    weight = "Medium", -- Regular | Medium | Bold
    stretch = "Normal",
    style = "Normal",
})

M.bold_brightens_ansi_colors = true

M.exit_behavior = "Close"

M.colors = {
      -- The default text color
      foreground = "silver",
      -- The default background color
      background = "black",

      -- Overrides the cell background color when the current cell is occupied by the
      -- cursor and the cursor style is set to Block
      cursor_bg = "#52ad70",
      -- Overrides the text color when the current cell is occupied by the cursor
      cursor_fg = "black",
      -- Specifies the border color of the cursor when the cursor style is set to Block,
      -- or the color of the vertical or horizontal bar when the cursor style is set to
      -- Bar or Underline.
      cursor_border = "#52ad70",

      -- the foreground color of selected text
      selection_fg = "black",
      -- the background color of selected text
      selection_bg = "#fffacd",

      -- The color of the scrollbar "thumb"; the portion that represents the current viewport
      scrollbar_thumb = "#222222",

      -- The color of the split lines between panes
      split = "#444444",

      ansi = {"black", "maroon", "green", "olive", "navy", "purple", "teal", "silver"},
      brights = {"grey", "red", "lime", "yellow", "blue", "fuchsia", "aqua", "white"},

      -- Arbitrary colors of the palette in the range from 16 to 255
      indexed = {[136] = "#af8700"},

      -- Since: 20220319-142410-0fcdea07
      -- When the IME, a dead key or a leader key are being processed and are effectively
      -- holding input pending the result of input composition, change the cursor
      -- to this color to give a visual cue about the compose state.
      compose_cursor = "orange",
  }

return M
