{
  home-manager,
  pkgs,
  homeDirectory,
  ...
}:

let
  font = "JetBrainsMono Nerd Font";
in {
  imports = [
    ./user/gtk.nix
    (import ./sway.nix { inherit pkgs homeDirectory font; })
  ];

  programs = {
    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [];
      inheritType = "any";
    };
    # zsh.shellAliases = {
    #   gpg = "${pkgs.gnupg}/bin/gpg --no-autostart";
    # };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox-wayland}/bin/firefox";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${homeDirectory}/desk";
    documents = "${homeDirectory}/docs";
    download = "${homeDirectory}/down";
    music = "${homeDirectory}/music";
    pictures = "${homeDirectory}/pics";
    publicShare = "${homeDirectory}/share";
    templates = "${homeDirectory}/templates";
    videos = "${homeDirectory}/vids";
    extraConfig = {
        XDG_MISC_DIR = "${homeDirectory}/misc";
    };
  };
}

