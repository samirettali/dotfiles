{pkgs, ...}: {
  home.packages = with pkgs; [
    pinentry-qt
  ];

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings = {
        reader-port = "Yubico Yubi";
      };
    };

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [];
      inheritType = "any";
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableScDaemon = true;
    };
  };
}
