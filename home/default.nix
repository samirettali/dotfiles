{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./sops.nix
    ./dotfiles.nix
    ./shell
    ./services/default.nix
  ];

  home.sessionVariables = {
    DEFAULT_BROWSER = "chrome";
    TERMINAL = "ghostty";
    MANPAGER = "${lib.getExe inputs.neovim-nightly-overlay.packages.${pkgs.system}.default} -c 'Man!' -";
  };

  programs = {
    home-manager.enable = true;
    ncspot = {
      enable = true;
      settings = {
        shuffle = true;
        gapless = true;
      };
    };
  };

  home.packages = with pkgs; [
    aider-chat
    nix-prefetch-github
    nix-init
    sops
    (buildGoModule {
      pname = "git-sync";
      version = "latest";
      src = fetchFromGitHub {
        owner = "AkashRajpurohit";
        repo = "git-sync";
        rev = "main";
        sha256 = "sha256-GBDC6lQGNDE6G8gIYqQPVeqqrGwW/h2ZRhtJU1x+LKo=";
      };
      vendorHash = "sha256-VJLdAkONyJiyQTtrZ9xwVXTqpkbHsIbVgOAu2RA62ao=";
    })
  ];

  home.file.".hushlogin".text = "";
}
