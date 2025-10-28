{
  customArgs,
  lib,
  ...
}: {
  programs.zed-editor = {
    enable = lib.mkDefault true;

    extensions = [
      "csharp"
      "csv"
      "docker-compose"
      "dockerfile"
      "env"
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
      agent_servers = {
        gemini = {
          ignore_system_version = false;
        };
      };
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
      debugger = {
        dock = "right";
      };
      outline_panel = {
        "dock" = "right";
      };
      scrollbar = {
        "git_diff" = false;
      };
      tab_size = 4;
      tab_bar = {
        "show_nav_history_buttons" = false;
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      tabs = {
        # file_icons = true;
        git_status = true;
        show_diagnostics = "errors";
      };
      theme = {
        mode = "system";
        light = "Gruvbox Light Soft";
        dark = "Fleet Dark";
      };
      toolbar = {
        quick_actions = false;
      };
      relative_line_numbers = true;
      ui_font_family = customArgs.font.name;
      ui_font_size = 16;
      vim_mode = true;
      soft_wrap = "editor_width";
      inlay_hints = {
        show_value_hints = false;
      };
      notification_panel = {
        dock = "left";
      };
      chat_panel = {
        dock = "left";
      };
      project_panel = {
        dock = "right";
        indent_size = 16;
        git_status = true;
      };
      vertical_scroll_margin = 20;
      features = {
        edit_prediction_provider = "zed";
      };
      scrollbar = {
        show = "never";
      };
      indent_guides = {
        enabled = false;
      };
      agent = {
        enabled = true;
        button = true;
        dock = "right";
        default_width = 640;
        default_height = 320;
        default_view = "thread";
        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4";
        };
        single_file_review = true;
      };
      file_types = {
        Dockerfile = ["Dockerfile" "Dockerfile.*"];
      };
      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        # above is default from Zed
        "**/out"
        "**/dist"
        "**/.husky"
        "**/.turbo"
        "**/.vscode-test"
        "**/.vscode"
        "**/.next"
        "**/.storybook"
        "**/.tap"
        "**/.nyc_output"
        "**/report"
        "**/node_modules"
      ];
    };
  };
}
