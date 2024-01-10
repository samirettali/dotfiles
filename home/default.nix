{ ... }: {
  imports = [
    ./dotfiles.nix
    ./shell
    ./common/alacritty.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "foot";
      TERM = "xterm-256color";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
