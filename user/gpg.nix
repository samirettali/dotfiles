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
    # pcscd.enable = true;
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableExtraSocket = true;
      enableScdaemon = true;
    };
  };

}
