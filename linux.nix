{ home-manager
, pkgs
, homeDirectory
, nixpkgs
, ...
}:

let
  font = "JetBrainsMono Nerd Font";
in
{
  imports = [
    ./user/gtk.nix
    ./programs/kanshi.nix
    (import ./sway.nix { inherit pkgs homeDirectory font nixpkgs; })
    (import ./programs/foot.nix { inherit font; })
  ];

  programs = {
    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [ ];
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
    BEMENU_OPTS = "--fn 'JetBrainsMono Nerd Font' --prompt '' --nb '#000000' --nf '#ffffff' --ab '#000000' --af '#ffffff' --sb '#ffffff' --sf '#ffffff' --hb '#ffffff' --hf '#000000' --tb '#000000' --tf '#ffffff' --fb '#000000' --ff '#ffffff' --hp 10 -H 24";
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
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gtk2";
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

