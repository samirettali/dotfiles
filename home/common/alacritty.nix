{ ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium";
        };
        italic = { style = "Medium"; };
        bold = { style = "Medium"; };
        bold_italic = { style = "Medium"; };
        size = 12;
      };

      draw_bold_text_with_bright_colors = true;

      colors = {
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
    };
  };
}