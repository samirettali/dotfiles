{ ... }: {
  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require "wezterm"
        local M = {}

        if wezterm.config_builder then
          M = wezterm.config_builder()
        end

        M.color_scheme = "Builtin Dark"
        M.font_size = 15
        M.adjust_window_size_when_changing_font_size = false
        M.enable_wayland = true
        M.enable_tab_bar = false

        M.window_padding = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        }

        M.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Regular", italic = false })

        M.custom_block_glyphs = false
        M.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
        M.freetype_load_target = "HorizontalLcd"

        M.bold_brightens_ansi_colors = true

        M.exit_behavior = "Close"

        return M
      '';
    };
  };
}
