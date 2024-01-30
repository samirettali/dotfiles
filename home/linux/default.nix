{ pkgs
, ...
}: {
  imports = [
    ./gpg.nix
  ];

  home.packages = with pkgs; [
    bcc
  ];

  programs = {
    zsh = {
      shellAliases = {
        ls = "ls --group-directories-first --color=auto";
      };
    };
  };
}
