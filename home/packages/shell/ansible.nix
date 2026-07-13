{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dotfiles.programs.ansible;
  mitogen = pkgs.python3Packages.mitogen;
  mitogenStrategyPath = "${mitogen}/${pkgs.python3.sitePackages}/ansible_mitogen/plugins/strategy";
in {
  home.packages = lib.optionals cfg.enable (with pkgs; [
    ansible
    mitogen
  ]);

  home.sessionVariables = lib.optionalAttrs cfg.enable {
    ANSIBLE_STRATEGY_PLUGINS = mitogenStrategyPath;
  };
}
