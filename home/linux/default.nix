{ pkgs, ... }: {
  imports = [
    ./gpg.nix
  ];

  programs = {
    zsh = {
      shellAliases = {
        ls = "ls --group-directories-first --color=auto";
      };
    };
  };
}
