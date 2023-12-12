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
    ./user/gpg.nix
    ./programs/mpv.nix
    (import ./programs/mpv.nix { inherit pkgs; })
    (import ./programs/kanshi.nix { inherit pkgs; })
    (import ./sway.nix { inherit pkgs homeDirectory font nixpkgs; })
    (import ./programs/foot.nix { inherit font; })
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox-wayland}/bin/firefox";
    BEMENU_OPTS = "--center --accept-single -W 0.3 --binding vim --vim-esc-exits -l 10 --fn '${font} 14' -p '' --border 2 --ignorecase --wrap --fixed-height";
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
