{ pkgs
, ...
}: {
  imports = [
    ./dotfiles.nix
    ./shell
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    TERM = "xterm-256color";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    ollama
  ];
}
