{pkgs, ...}: {
  imports = [
    ./dotfiles.nix
    ./shell
    ./services/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "chrome";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    aider-chat
    nix-prefetch-github
    (buildGoModule {
      pname = "git-sync";
      version = "latest";
      src = fetchFromGitHub {
        owner = "AkashRajpurohit";
        repo = "git-sync";
        rev = "main";
        sha256 = "sha256-4XTNmucVXBbWoMLXSjXWQCHkuNLVTrrsqYTTF+6D78o=";
      };
      vendorHash = "sha256-c7XDEw85DqvXeFLRFn8gY4aUNAz7hkkFyP4eVD8LQrg=";
    })
  ];
}
