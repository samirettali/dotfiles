{ pkgs, ... }: {
  imports = [
    ./hyprland.nix
    ./sway.nix
    ./waybar.nix
    ./swaylock.nix
    ./mako.nix
    ./gtk.nix
    ./kanshi.nix
  ];

  home.packages = with pkgs; [
    bemenu
    swaybg
    hyprpicker
    grimblast
    zathura
    cinnamon.nemo
    cliphist
    pavucontrol
    ffmpegthumbnailer
    wl-clipboard
    wlprop
    networkmanagerapplet
    imv
    xdg-utils
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    # BEMENU_BACKEND = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    BEMENU_OPTS = "--center --accept-single -W 0.3 --binding vim --vim-esc-exits -l 10 --fn 'JetBrainsMono Nerd Font 14' -p '' --border 2 --ignorecase --wrap --fixed-height";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "desk";
    documents = "docs";
    download = "down";
    music = "music";
    pictures = "pics";
    publicShare = "share";
    templates = "templates";
    videos = "vids";
  };
}