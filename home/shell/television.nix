{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.television = {
    enable = true;
    package = inputs.television.packages.${pkgs.system}.default;
    # enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };

  # TODO: upstream is broken
  programs.fish.interactiveShellInit = lib.mkIf true ''
    tv init fish | source
  '';
}
