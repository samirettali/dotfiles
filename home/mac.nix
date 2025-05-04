{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    asitop
    docker
  ];
  home.file = {
    ".hammerspoon/Spoons/Hammerflow.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "saml-dev";
        repo = "Hammerflow.spoon";
        rev = "main";
        sha256 = "sha256-nsRDVLRRnPyp3Yi3l2e+atonQt3zU0lK43RH6VruUJ0=";
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

  home.sessionPath = [
    "${config.home.homeDirectory}/.orbstack/bin"
  ];
}
