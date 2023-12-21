{ ... }: {
  imports = [
    ./dotfiles.nix
    ./shell
    ./common/alacritty.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
