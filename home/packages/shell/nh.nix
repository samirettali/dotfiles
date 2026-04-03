{config, ...}: {
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep 1";
    };
    flake = config.home.homeDirectory + "/dev/dotfiles"; # TODO: is there a better way to do this?
  };
}
