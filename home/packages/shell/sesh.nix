{
  config,
  pkgs,
  ...
}: {
  programs.sesh = {
    enable = config.programs.tmux.enable;
  };
}
