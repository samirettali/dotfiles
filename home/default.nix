{pkgs, ...}: {
  imports = [
    ./sops.nix
    ./dotfiles.nix
    ./shell
    ./services/default.nix
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = "chrome";
    TERMINAL = "ghostty";
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
        sha256 = "sha256-fBNtOkNUhK4q0XttO94Ksxdtn5+GiySVOPafdHveUbw=";
      };
      vendorHash = "sha256-HLtAcOkNvNfDvmBrR/Mps2vAcaiBv3cPCbK3B02GFAk=";
    })
  ];

  home.file.".hushlogin".text = "";
}
