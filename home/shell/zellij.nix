{
  pkgs,
  lib,
  config,
  samirettali-nur,
  ...
}: let
  exe = lib.getExe config.programs.zellij.package;

  zellij-autolock = pkgs.fetchurl {
    url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
    sha256 = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
  };

  zellij-sessionizer = pkgs.fetchurl {
    url = "https://github.com/laperlej/zellij-sessionizer/releases/download/v0.4.3/zellij-sessionizer.wasm";
    sha256 = "sha256-AGuWbuRX7Yi9tPdZTzDKULXh3XLUs4navuieCimUgzQ=";
  };
in {
  home.packages = [
    samirettali-nur.packages.${pkgs.system}.zesh
    pkgs.zjstatus
  ];

  programs = {
    zellij = {
      enable = true;
    };
  };

  home.shellAliases = {
    za = "${exe} attach -c";
    zd = "${exe} delete-session";
    zk = "${exe} kill-session";
    zl = "${exe} list-sessions";
  };

  xdg.configFile."zellij/layouts/default.kdl" = {
    enable = config.programs.zellij.enable;
    text =
      /*
      kdl
      */
      ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                        format_left  "{mode}#[fg=green,bg=black,bold] [{session}]#[bg=#000000] {tabs}"
                        format_right "#[fg=#gray,bg=black]"
                        format_space "#[bg=black]"

                        mode_normal          "#[bg=bright_blue] "
                        mode_tmux            "#[bg=bright_green] "
                        mode_resize          "#[bg=bright_cyan] "
                        mode_move            "#[bg=bright_magenta] "
                        mode_locked          "#[bg=bright_red] "
                        mode_default_to_mode "locked"

                        tab_normal               "#[fg=gray,bg=black] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                        tab_active               "#[fg=white,bg=black,bold] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"

                        tab_fullscreen_indicator "□ "
                        tab_sync_indicator       "  "
                        tab_floating_indicator   "󰉈 "

                        command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format      "#[fg=bright_blue] {stdout} "
                        command_git_branch_interval    "1"
                        command_git_branch_rendermode  "static"
                    }
                }
            }
        }
      '';
  };

  xdg.configFile."zellij/config.kdl" = {
    enable = config.programs.zellij.enable;
    text =
      /*
      kdl
      */
      ''
        keybinds clear-defaults=true {
            locked {
                bind "Alt q" { SwitchToMode "normal"; }
                bind "Alt z" {
                    MessagePlugin "autolock" { payload "disable"; };
                    SwitchToMode "Normal";
                }
            }
            shared {
                bind "Alt Shift z" {
                    MessagePlugin "autolock" { payload "enable"; };
                }
                bind "Alt n" { NewPane; }
            }
            shared_except "locked" {
                bind "Alt q" { SwitchToMode "locked"; }
                bind "Ctrl h" { MoveFocus "Left"; }
                bind "Ctrl l" { MoveFocus "Right"; }
                bind "Ctrl j" { MoveFocus "Down"; }
                bind "Ctrl k" { MoveFocus "Up"; }
            }
            shared_except "locked" "move" {
                bind "Ctrl m" { SwitchToMode "move"; }
            }
            shared_except "normal" "locked" {
                bind "esc" { SwitchToMode "normal"; }
            }
            renametab {
                bind "enter" { SwitchToMode "normal"; }
            }
            shared_except  "scroll" "search" "tmux" {
                bind "Ctrl a" { SwitchToMode "tmux"; }
                bind "Ctrl \\" { SwitchToMode "tmux"; }
                bind "Ctrl b" { SwitchToMode "tmux"; }
            }
            tmux {
                // brackets after NewTab are required to open the tab in the current working directory
                bind "Ctrl c" { NewTab { }; SwitchToMode "normal"; }
                bind "c" { NewTab { }; SwitchToMode "normal"; }

                bind "n" { GoToNextTab; SwitchToMode "normal"; }
                bind "Ctrl n" { GoToNextTab; }

                bind "p" { GoToPreviousTab; SwitchToMode "normal"; }
                bind "Ctrl p" { GoToPreviousTab; SwitchToMode "normal"; }

                bind "s" { NewPane "down"; SwitchToMode "normal"; }
                bind "Ctrl s" { NewPane "down"; SwitchToMode "normal"; }

                bind "v" { NewPane "right"; SwitchToMode "normal"; }
                bind "Ctrl v" { NewPane "right"; SwitchToMode "normal"; }

                bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }
                bind "Ctrl z" { ToggleFocusFullscreen; SwitchToMode "normal"; }

                bind "b" { BreakPane; SwitchToMode "normal"; }
                bind "Ctrl b" { BreakPane; SwitchToMode "normal"; }

                bind "[" { SwitchToMode "scroll"; }
                bind "Ctrl [" { SwitchToMode "scroll"; }

                bind "," { SwitchToMode "renametab"; }
                bind "Ctrl ," { SwitchToMode "renametab"; }
                bind "m" { SwitchToMode "move"; } // TODO: map also in resize mode
                bind "o" { SwitchToMode "session"; }
                bind "r" { SwitchToMode "resize"; }

                bind "/" { SwitchToMode "entersearch"; }

                bind "x" { CloseFocus; SwitchToMode "normal"; }

                bind "d" { Detach; }
                bind "Ctrl d" { Detach; }

                bind "space" { NextSwapLayout; }

                bind "f" { ToggleFloatingPanes; SwitchToMode "normal"; }
                bind "Ctrl f" { ToggleFloatingPanes; SwitchToMode "normal"; }

                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
                bind "Ctrl e" { TogglePaneEmbedOrFloating; }

                bind "i" { TogglePanePinned; SwitchToMode "normal"; }
                bind "Ctrl i" { TogglePanePinned; }

                bind "P" { TogglePaneFrames; }

                bind "h" { GoToPreviousTab; }
                bind "l" { GoToNextTab; }
                bind "<" { MoveTab "left"; SwitchToMode "normal"; }
                bind ">" { MoveTab "right"; SwitchToMode "normal"; }

                bind "{" { MovePaneBackwards; SwitchToMode "normal"; }
                bind "}" { MovePane; SwitchToMode "normal"; }

                bind "w" {
                    LaunchOrFocusPlugin "session-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "normal"
                }
                bind "X" {
                    LaunchOrFocusPlugin "plugin-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "normal"
                }
                bind "S" { ToggleActiveSyncTab; SwitchToMode "normal"; }
                bind "tab" { ToggleTab; SwitchToMode "normal"; }
                bind "1" { GoToTab 1; SwitchToMode "normal"; }
                bind "2" { GoToTab 2; SwitchToMode "normal"; }
                bind "3" { GoToTab 3; SwitchToMode "normal"; }
                bind "4" { GoToTab 4; SwitchToMode "normal"; }
                bind "5" { GoToTab 5; SwitchToMode "normal"; }
                bind "6" { GoToTab 6; SwitchToMode "normal"; }
                bind "7" { GoToTab 7; SwitchToMode "normal"; }
                bind "8" { GoToTab 8; SwitchToMode "normal"; }
                bind "9" { GoToTab 9; SwitchToMode "normal"; }
                bind "0" { GoToTab 10; SwitchToMode "normal"; }

                bind "g" {
                    LaunchOrFocusPlugin "file:${builtins.unsafeDiscardStringContext zellij-sessionizer}" {
                        floating true
                        move_to_focused_tab true
                        cwd "/"
                        root_dirs "/Users/s.ettali/dev;Users/s.ettali/proj;/Users/s.ettali/go/src/github.com/YoungAgency" // TODO: hardcoded
                        session_layout "compact"
                    };
                    SwitchToMode "Locked";
                }
            }
            resize {
                bind "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
                bind "=" { Resize "Increase"; }
                bind "H" { Resize "Decrease left"; }
                bind "J" { Resize "Decrease down"; }
                bind "K" { Resize "Decrease up"; }
                bind "L" { Resize "Decrease right"; }
                bind "h" { Resize "Increase left"; }
                bind "j" { Resize "Increase down"; }
                bind "k" { Resize "Increase up"; }
                bind "l" { Resize "Increase right"; }
                bind "Ctrl n" { SwitchToMode "normal"; }
            }
            move {
                bind "h" { MovePane "left"; }
                bind "j" { MovePane "down"; }
                bind "k" { MovePane "up"; }
                bind "l" { MovePane "right"; }
                bind "n" { MovePane; }
                bind "p" { MovePaneBackwards; }
                bind "tab" { MovePane; }
                bind "<" { MoveTab "left"; }
                bind ">" { MoveTab "right"; }
            }
            scroll {
                bind "e" { EditScrollback; SwitchToMode "normal"; }
                bind "s" { SwitchToMode "entersearch"; SearchInput 0; }
            }
            shared_among "scroll" "search" {
                bind "Ctrl b" { PageScrollUp; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }
                bind "d" { HalfPageScrollDown; }
                bind "Ctrl f" { PageScrollDown; }
                bind "h" { PageScrollUp; }
                bind "j" { ScrollDown; }
                bind "k" { ScrollUp; }
                bind "l" { PageScrollDown; }
                bind "Ctrl s" { SwitchToMode "normal"; }
                bind "u" { HalfPageScrollUp; }
            }
            entersearch {
                bind "enter" { SwitchToMode "search"; }
            }
            normal {
                bind "Enter" {
                    WriteChars "\u{000D}";
                    MessagePlugin "autolock" {};
                }
            }
        }

        plugins {
            about location="zellij:about"
            compact-bar location="zellij:compact-bar"
            configuration location="zellij:configuration"
            filepicker location="zellij:strider" {
                cwd "/"
            }
            plugin-manager location="zellij:plugin-manager"
            session-manager location="zellij:session-manager"
            status-bar location="zellij:status-bar"
            strider location="zellij:strider"
            tab-bar location="zellij:tab-bar"
            welcome-screen location="zellij:session-manager" {
                welcome_screen true
            }

            autolock location="file:${builtins.unsafeDiscardStringContext zellij-autolock}" {
                is_enabled true
                triggers "nvim|vim|git|fzf|zoxide|atuin|lazygit"
                reaction_seconds "0.1"
                print_to_log true
            }

            zellij-session location="file:${builtins.unsafeDiscardStringContext zellij-sessionizer}" { }
        }

        load_plugins {
            autolock
        }

        simplified_ui true
        default_mode "normal"
        default_layout "default"
        mouse_mode true
        pane_frames false
        copy_on_select true
        show_startup_tips false
        session_name "default"
        attach_to_session true
        auto_layout true

        session_serialization true
        serialize_pane_viewport true
        scrollback_lines_to_serialize 10000
        serialization_interval 10000
        disable_session_metadata false
        styled_underlines false
        stacked_resize false

        theme "default"

        themes {
            default {
                text_unselected {
                    base 15
                    background 0
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                text_selected {
                    base 15
                    background 8
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                ribbon_unselected {
                    base 0
                    background 7
                    emphasis_0 1
                    emphasis_1 15
                    emphasis_2 4
                    emphasis_3 5
                }
                ribbon_selected {
                    base 0
                    background 2
                    emphasis_0 1
                    emphasis_1 9
                    emphasis_2 5
                    emphasis_3 4
                }
                table_title {
                    base 2
                    background 0
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                table_cell_unselected {
                    base 15
                    background 0
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                table_cell_selected {
                    base 15
                    background 8
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                list_unselected {
                    base 15
                    background 0
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                list_selected {
                    base 15
                    background 8
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 2
                    emphasis_3 5
                }
                frame_selected {
                    base 2
                    background 0
                    emphasis_0 9
                    emphasis_1 6
                    emphasis_2 5
                    emphasis_3 0
                }
                frame_highlight {
                    base 9
                    background 0
                    emphasis_0 5
                    emphasis_1 9
                    emphasis_2 9
                    emphasis_3 9
                }
                exit_code_success {
                    base 2
                    background 0
                    emphasis_0 6
                    emphasis_1 0
                    emphasis_2 5
                    emphasis_3 4
                }
                exit_code_error {
                    base 1
                    background 0
                    emphasis_0 3
                    emphasis_1 0
                    emphasis_2 0
                    emphasis_3 0
                }
                multiplayer_user_colors {
                    player_1 5
                    player_2 4
                    player_3 0
                    player_4 3
                    player_5 6
                    player_6 0
                    player_7 1
                    player_8 0
                    player_9 0
                    player_10 0
                }
            }
        }
      '';
  };
}
