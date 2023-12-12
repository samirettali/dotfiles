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

  home.packages = with pkgs; [
    pinentry-gtk2
  ];

  programs = {
    gpg = {
      enable = true;
    };

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [ ];
      inheritType = "any";
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableExtraSocket = true;
      enableScDaemon = true;
    };
  };

}
