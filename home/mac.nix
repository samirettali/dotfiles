{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    asitop
    # docker
  ];
  home.file = {
    ".hammerspoon/Spoons/Hammerflow.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "samirettali";
        repo = "Hammerflow.spoon";
        rev = "main";
        sha256 = "sha256-Tk0SNGQ6hiINmNxJj9jZIXuc1v2eKz/dE68ejOeztFc=";
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
      shellAliases = {
        ls = "${pkgs.coreutils}/bin/ls --color=auto --group-directories-first --indicator-style none";
      };
    };
  };

  # home.sessionPath = [
  #   "${config.home.homeDirectory}/.orbstack/bin"
  # ];
}
