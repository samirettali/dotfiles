{ config, pkgs, lib, ... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  font = "JetBrainsMono Nerd Font";

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

in

{
  imports = [
    ./user/zsh.nix
    ./user/gtk.nix
    ./user/fzf.nix
    ./user/git.nix
  ];

  home.stateVersion = "23.11";
  home.username = "samir";
  home.homeDirectory = "/home/samir";

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.ripgreprc";
  };

  programs =  {
    home-manager.enable = true;
    i3status-rust = {
        enable = true;
        bars = {
            default = {
                blocks = [
                    {
                        block = "keyboard_layout";
                        driver = "sway";
                        mappings = {
                            "English (US)" = "us";
                            "Italian" = "it";
                        };
                    }
                    { block = "sound"; }
                    {
                        block = "time";
                        format = " $timestamp.datetime(f:'%a %d/%m %R') ";
                        interval = 1;
                    }
                ];
                settings = {
                    theme = {
                        theme = "plain";
                        overrides = {
                            idle_bg = "#000000";
                            idle_fg = "#ffffff";
                        };
                    };
                };
            };
        };
    };
  };

  wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = rec {
          bars = [
              {
                fonts = {
                    names = [ "${font}" ];
                    style = "Regular";
                    size = 10.0;
                };
                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.home.homeDirectory}/.config/i3status-rust/config-default.toml";
                trayOutput = "primary";
                mode = "dock";
                position = "top";
              }
          ];
          floating = {
              criteria = [
                  { class = "Pavucontrol"; }
                  { class = "nemo"; }
                  { window_role = "pop-up"; }
                  { window_role = "task_dialog"; }
              ];
          };
          focus.followMouse = true;
          fonts = {
              names = [ "${font}" ];
              style = "Regular";
              size = 10.0;
          };
          gaps = {
              inner = 0;
              outer = 0;
              smartBorders = "on";
              # smartGaps = true;
          };
          input = {
              "*" = {
                  xkb_layout = "us,it";
                  repeat_delay = "200";
                  repeat_rate = "60";
              };
          };
          keybindings = let
              modifier = config.wayland.windowManager.sway.config.modifier;
              in lib.mkOptionDefault {
                  "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
                  "${modifier}+Shift+c" = "kill";
                  "${modifier}+Shift+r" = "reload";
                  "${modifier}+Shift+q" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
                  "${modifier}+p" = "exec ${pkgs.bemenu}/bin/bemenu-run";
                  "${modifier}+Tab" = "workspace back_and_forth";
                  "${modifier}+x" = "exec ${pkgs.cinnamon.nemo}/bin/nemo";
                  "${modifier}+y" = "exec ${pkgs.hyprpicker}/bin/hyprpicker | wl-copy";
                  "${modifier}+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
                  "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
                  "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          };
          modifier = "Mod4";
          output = {
            "*" = {
                  bg = "/home/samir/pics/walls/oxomfy9gqwgb1.jpg fill";
              };
          };
          startup = [
              { command = "nm-applet";}
              { command = "wl-paste --watch cliphist store"; }
              { command = "xrdb -merge ~/.Xresources"; }
              { command = "mako"; }
              { command = "kanshi"; always = true; }
              { command = "exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
          ];
          terminal = "foot";
          window = {
              border = 4;
              titlebar = false;
          };
          workspaceAutoBackAndForth = true;
      };
  };

  services = {
    mpris-proxy.enable = true;
    mako = {
      enable = true;
      anchor = "top-right";
      defaultTimeout = 5000;
      font = "${font}";
      layer = "top";
      groupBy = "app-name";
    };
  };

  # (pkgs.writeShellScriptBin "my-hello" ''
  # '')

  home.file = {
    ".config/wezterm/wezterm.lua".source = dotfiles/wezterm.lua;
    ".Xresources".source = dotfiles/Xresources;
    ".ackrc".source = dotfiles/ackrc;
    ".config/alacritty/alacritty.yml".source = dotfiles/alacritty.yml;
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/foot/foot.ini".source = dotfiles/foot.ini;
    ".tmux.conf".source = dotfiles/tmux.conf;
    ".ripgreprc".source = dotfiles/ripgreprc;
    ".config/kanshi/config".source = dotfiles/kanshi_config;
    ".config/bc".source = dotfiles/bc;
    ".config/mpv" = { source = dotfiles/mpv; recursive = true; };
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".bin" = { source = dotfiles/scripts; recursive = true; };
  };

  home.packages = with pkgs; [
    grim
    slurp
    kanshi
    wl-clipboard
    cliphist
    bemenu
    wbg
    wdisplays
    xorg.xrdb
    hyprpicker

    dbus-sway-environment
    configure-gtk
    xdg-utils

    foot

    # desktop apps
    wezterm
    keepassxc
    vscode
    spotify
    qbittorrent

    firefox-wayland
    mpv
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    webp-pixbuf-loader
    pavucontrol
    sxiv

    neovim-nightly

    # cli tools
    direnv
    unixtools.xxd
    fzf
    tmux
    zellij
    entr
    tree
    jq
    htop
    lazygit
    lazydocker
    fd
    ripgrep
    moreutils
    ranger
    tmuxinator
    espanso
    iredis
    pgcli
    ncdu
    ngrok
    mprocs

    tor-browser-bundle-bin

    pkgs.tree-sitter
    pkgs.networkmanagerapplet

    pamixer
    trash-cli
    p7zip
    unzip

    docker-compose

    lua-language-server
    nixd

    nodejs

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gcc
    gnumake
    cmake

    openssl
    pkg-config

    zig
    zls

    dnsx
    httpx

    (fenix.combine [
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      fenix.targets.wasm32-unknown-unknown.latest.rust-std
    ])
    rust-analyzer-nightly
    cargo-watch
    cargo-shuttle
    trunk
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/desk";
    documents = "${config.home.homeDirectory}/docs";
    download = "${config.home.homeDirectory}/down";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/pics";
    publicShare = "${config.home.homeDirectory}/share";
    templates = "${config.home.homeDirectory}/templates";
    videos = "${config.home.homeDirectory}/vids";
    extraConfig = {
        XDG_MISC_DIR = "${config.home.homeDirectory}/misc";
    };
  };
}
