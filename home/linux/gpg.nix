{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pinentry-qt
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
      pinentryFlavor = "qt";
      enableExtraSocket = true;
      enableScDaemon = true;
    };
  };
}
