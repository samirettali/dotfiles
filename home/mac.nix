{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    asitop
    # docker
    blueutil
  ];

  home.file = {
    # TODO: use when PR is merged
    # ".hammerspoon/Spoons/Hammerflow.spoon" = {
    #   source = pkgs.fetchFromGitHub {
    #     owner = "saml-dev";
    #     repo = "Hammerflow.spoon";
    #     rev = "main";
    #     sha256 = "sha256-nsRDVLRRnPyp3Yi3l2e+atonQt3zU0lK43RH6VruUJ0=";
    #   };
    # };
    # ".hammerspoon/Spoons/Hammerflow.spoon" = {
    #   source = pkgs.fetchFromGitHub {
    #     owner = "samirettali";
    #     repo = "Hammerflow.spoon";
    #     # rev = "feat-alert-style";
    #     # sha256 = "sha256-9SzTtvwDe/ZB7ywwwQGs6Z0xfBeAhbMMiAREfUfBiYU=";
    #     rev = "db83294284365b643e1449a7f1ee12bd64ffbd26";
    #     sha256 = "sha256-Uytd8+Lhuo83DtQHwbnUxoq3fTyU01LBcatlxigj6cQ=";
    #   };
    # };
    # ".hammerspoon/Spoons/ControlEscape.spoon" = {
    #   source = pkgs.fetchFromGitHub {
    #     owner = "jasonrudolph";
    #     repo = "ControlEscape.spoon";
    #     rev = "main";
    #     sha256 = "sha256-aTCjdTdDOQMFcML4/C2M7dBPwkI4paOjQR7euNDRuao=";
    #   };
    # };
    ".hammerspoon/Spoons/SkyRocket.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "samirettali";
        repo = "SkyRocket.spoon";
        rev = "main";
        sha256 = "sha256-AJEuFRRF21jm3dWW2cO+r7Attxcs28NTqJhdLsV3fkw=";
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
