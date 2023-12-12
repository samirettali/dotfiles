{ home-manager
, pkgs
, homeDirectory
, nixpkgs
, ...
}:

let
  font = "JetBrainsMono Nerd Font";
  browser = "firefox";
in
{
  imports = [
    ./user/gtk.nix
    ./user/gpg.nix
    ./programs/mpv.nix
    (import ./programs/pass.nix { inherit pkgs nixpkgs browser; })
    (import ./programs/mpv.nix { inherit pkgs; })
    (import ./sway.nix { inherit pkgs homeDirectory font nixpkgs; })
    (import ./programs/kanshi.nix { inherit pkgs; })
    (import ./programs/foot.nix { inherit font; })
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = browser;
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
