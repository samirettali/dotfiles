{pkgs, ...}: {
  home.packages = with pkgs; [
    asitop
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
}
