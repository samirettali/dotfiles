{pkgs, ...}: {
  imports = [
    ./sops.nix
    ./dotfiles.nix
    ./shell
    ./services/default.nix
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = "chrome";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    aider-chat
    nix-prefetch-github
    sops
    (buildGoModule {
      pname = "git-sync";
      version = "latest";
      src = fetchFromGitHub {
        owner = "AkashRajpurohit";
        repo = "git-sync";
        rev = "main";
        sha256 = "sha256-HbEv5BxE1Tjw5p1s+eb3aONZ+j3OZhw2pd+0l0oy058=";
      };
      vendorHash = "sha256-KzdWUGSpBTgECeg95UWIkofE+/Jqy2KCv4gIPHvgzF0=";
    })
  ];
}
