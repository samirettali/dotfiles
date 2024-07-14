{ pkgs
, ...
}: {
  imports = [
    ./dotfiles.nix
    ./shell
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    TERM = "xterm-256color";
    DEFAULT_BROWSER = "brave";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    ollama
  ];
}
