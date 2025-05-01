{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    asitop
    docker
  ];
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
