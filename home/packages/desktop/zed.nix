{customArgs, ...}: {
  programs.zed-editor = {
    enable = true;
    extensions = [
      "csharp"
      "csv"
      "docker-compose"
      "dockerfile"
      "fleet-themes"
      "lua"
      "nix"
      "ruff"
      "sql"
      "terraform"
      "zig"
    ];

    userSettings = {
      auto_update = false;
      buffer_font_family = customArgs.font.name;
      buffer_font_features = {
        "calt" = false;
      };
      buffer_font_size = 14;
      buffer_font_weight = 600;
      cursor_blink = false;
      inlay_hints = {
        "enabled" = false;
      };
      journal = {
        "hour_format" = "hour24";
      };
      outline_panel = {
        "dock" = "right";
      };
      scrollbar = {
        "git_diff" = false;
      };
      tab_bar = {
        "show_nav_history_buttons" = false;
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      theme = "Fleet Dark";
      toolbar = {
        quick_actions = false;
      };
      ui_font_family = customArgs.font.name;
      ui_font_size = 16;
      vim_mode = true;
      soft_wrap = "editor_width";
    };
  };
}
