{pkgs, ...}: {
  home.packages = with pkgs; [
    asitop
    nur.repos.natsukium.hammerspoon
    # docker
  ];

  home.file = {
    ".hammerspoon/Spoons/RecursiveBinder.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "samirettali";
        repo = "RecursiveBinder.spoon";
        rev = "main";
        sha256 = "sha256-KcxZzYpfuCZy6p+ixvGJszKrRplPsXrr1ICfCw2k1xM=";
      };
    };
    ".hammerspoon/Spoons/ControlEscape.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "jasonrudolph";
        repo = "ControlEscape.spoon";
        rev = "main";
        sha256 = "sha256-aTCjdTdDOQMFcML4/C2M7dBPwkI4paOjQR7euNDRuao=";
      };
    };
  };

  programs = {
    gpg.enable = true;
    zsh = {
      initContent = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
  };

  home.file = {
    ".hammerspoon" = {
      source = dotfiles/hammerspoon;
      recursive = true;
    };
    ".config/sketchybar" = {
      source = dotfiles/sketchybar;
      recursive = true;
    };
  };
}
