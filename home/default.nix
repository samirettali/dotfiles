{ ... }: {
  imports = [
    ./dotfiles.nix
    ./shell
    ./common/alacritty.nix
    ./common/kitty.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    TERM = "xterm-256color";
  };

  programs = {
    home-manager.enable = true;
  };
}
