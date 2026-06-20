{pkgs, ...}: let
  mitogen = pkgs.python3Packages.mitogen;
  mitogenStrategyPath = "${mitogen}/${pkgs.python3.sitePackages}/ansible_mitogen/plugins/strategy";
in {
  home.packages = with pkgs; [
    ansible
    mitogen
  ];

  home.sessionVariables = {
    ANSIBLE_STRATEGY_PLUGINS = mitogenStrategyPath;
  };
}
