{config, ...}: {
  programs.sesh = {
    enable = config.programs.tmux.enable;
  };
}
