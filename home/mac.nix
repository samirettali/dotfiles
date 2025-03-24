{pkgs, ...}: {
  programs = {
    gpg.enable = true;
    zsh = {
      initExtra = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      shellAliases = {
        ls = "${pkgs.coreutils}/bin/ls --color=auto --group-directories-first --indicator-style none";
      };
    };
  };
}
