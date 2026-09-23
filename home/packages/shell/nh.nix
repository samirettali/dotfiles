{config, ...}: {
  programs.nh = {
    enable = true;
    flake = config.home.homeDirectory + "/dev/dotfiles"; # TODO: is there a better way to do this?
  };
}
