{ pkgs, ... }: {
  imports = [
    ./gpg.nix
    ./desktop.nix
  ];

  programs = {
    zsh = {
      shellAliases = {
        ls = "ls --group-directories-first --color=auto";
      };
    };
  };
}
