{
  customArgs,
  lib,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = false;
    settings = {
      terminal = {
        shell = "${lib.getExe pkgs.fish}";
      };
      font = {
        normal.family = customArgs.font.name;
        normal.style = "Regular";
        bold.style = "Medium";
        size = customArgs.font.size;
      };
      env = {
        TERM = "xterm-256color";
      };
      colors = {
        draw_bold_text_with_bright_colors = true;
        bright = {
          black = "#555555";
          blue = "#5555ff";
          cyan = "#55ffff";
          green = "#55ff55";
          magenta = "#ff55ff";
          red = "#ff5555";
          white = "#ffffff";
          yellow = "#ffff55";
        };
        cursor = {
          cursor = "#bbbbbb";
          text = "#ffffff";
        };
        normal = {
          black = "#000000";
          blue = "#0000bb";
          cyan = "#00bbbb";
          green = "#00bb00";
          magenta = "#bb00bb";
          red = "#bb0000";
          white = "#bbbbbb";
          yellow = "#bbbb00";
        };
        primary = {
          background = "#000000";
          foreground = "#bbbbbb";
        };
        selection = {
          background = "#b5d5ff";
          text = "#000000";
        };
      };
      window = {
        level = "AlwaysOnTop";
      };
    };
  };
}
