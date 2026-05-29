{
  samirettali-nur,
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.rift
  ];

  # create ~/.config/rift/config.toml if rift is installed by checking if rift is in the list of home.packages, and set some default settings
  xdg.configFile = {
    "rift/config.toml" = {
      enable = lib.elem samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.rift config.home.packages;
      force = true;
      text = ''
        [settings]
        animate = false

        focus_follows_mouse = false
        mouse_follows_focus = false
        mouse_hides_on_focus = false

        default_disable = false

        run_on_start = []

        hot_reload = true

        [settings.layout]
        mode = "traditional" # traditional | bsp | stack | master_stack

        [settings.layout.stack]
        stack_offset = 40.0

        [settings.layout.master_stack]
        master_ratio = 0.6
        master_count = 1
        master_side = "right"
        new_window_placement = "stack" # master | stack | focused

        [settings.ui.stack_line]
        enabled = false

        [settings.ui.menu_bar]
        enabled = false

        [settings.gestures]
        enabled = true
        invert_horizontal_swipe = true
        swipe_vertical_tolerance = 0.4
        skip_empty = true
        fingers = 3
        # Normalized horizontal distance (0..1) to trigger swipe for NSTouch-based detection
        distance_pct = 0.12
        haptics_enabled = true
        haptic_pattern = "level_change" # generic | alignment | level_change

        [virtual_workspaces]
        enabled = true
        default_workspace_count = 4
        auto_assign_windows = true
        preserve_focus_per_workspace = true
        workspace_auto_back_and_forth = true
        reapply_app_rules_on_title_change = false
        default_workspace = 0

        app_rules = [
          # { title_substring = "Info", floating = true },
          # { title_substring = "Trash", floating = true },
          # { app_id = "com.apple.SystemSettings", workspace = "", floating = true },
          # { app_id = "com.apple.systempreferences", workspace = "", floating = true },
          # { app_id = "cc.ffitch.shottr", workspace = "", floating = true },
          # { app_id = "com.pokerstars.PokerStars", workspace = "", floating = true },
          # { app_id = "com.apple.ActivityMonitor", floating = true },
          { app_id = "com.apple.calculator", floating = true },
          { app_id = "com.apple.systempreferences", floating = true },
          { app_id = "com.apple.finder", floating = true },
          { app_name = "Archive Utility", floating = true },
          { app_name = "Finder", floating = true },
          { app_id = "cc.ffitch.shottr", floating = true },
          # { title_substring = "Rabby Wallet Notification", workspace = "", floating = true },
          { app_id = "com.mitchellh.ghostty", workspace = 2 },
          # { app_id = "com.tinyspeck.slackmacgap", workspace = "4" },
          # { app_id = "com.postmanlabs.mac", workspace = "5" },
          # { app_id = "com.jetbrains.datagrip", workspace = "6" },
          # { app_id = "com.mongodb.compass", workspace = "6" },
          # { app_id = "org.RedisLabs.RedisInsight-V2", workspace = "6" },
          { app_id = "com.hnc.discord", workspace = 3},
          { app_id = "ru.keepcoder.Telegram", workspace = 3},
          { app_id = "com.spotify.client", workspace = 3},
          # { app_id = "org.keepassxc.keepassxc", workspace = "8" },
          { app_id = "com.apple.Preview", workspace = 3},
        ]

        [keys]
        "Alt + H" = { move_focus = "left" }
        "Alt + J" = { move_focus = "down" }
        "Alt + K" = { move_focus = "up" }
        "Alt + L" = { move_focus = "right" }
        "Alt + Shift + H" = { move_node = "left" }
        "Alt + Shift + J" = { move_node = "down" }
        "Alt + Shift + K" = { move_node = "up" }
        "Alt + Shift + L" = { move_node = "right" }

        # smartly resize windows
        "Alt + Shift + Equal" = "resize_window_grow"
        "Alt + Shift + Minus" = "resize_window_shrink"

        "Alt + F" = "toggle_fullscreen"
        "Alt + Shift + Space" = "toggle_window_floating"

        "Alt + 1" = { switch_to_workspace = 0 }
        "Alt + 2" = { switch_to_workspace = 1 }
        "Alt + 3" = { switch_to_workspace = 2 }
        "Alt + 4" = { switch_to_workspace = 3 }
        "Alt + Shift + 1" = { move_window_to_workspace = 0 }
        "Alt + Shift + 2" = { move_window_to_workspace = 1 }
        "Alt + Shift + 3" = { move_window_to_workspace = 2 }
        "Alt + Shift + 4" = { move_window_to_workspace = 3 }

        "Alt + Tab" = "switch_to_last_workspace"

        "Alt + Shift + Comma" = { move_window_to_display = { selector = "left" } }
        "Alt + Shift + Period" = { move_window_to_display = { selector = "right" } }

        "Alt + Shift + D" = "debug" # prints layout tree

        "Alt + Ctrl + S" = "serialize"
        "Alt + Ctrl + Q" = "save_and_exit"

        "Alt + E" = "toggle_stack"
        "Alt + A" = "toggle_orientation"
        "Alt + Enter" = "promote_to_master" # TODO: this is not working properly

        "Alt + Comma" = { focus_display = "left" }
        "Alt + Period" = { focus_display = "right" }

        "Alt + Ctrl + E" = "unjoin_windows"  # FIXME: doesnt work
        "Alt + Z" = "toggle_space_activated"
      '';
    };
  };
}
