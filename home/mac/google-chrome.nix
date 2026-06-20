{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;
  };

  home.sessionVariables = lib.mkIf config.programs.google-chrome.enable {
    BROWSER_BIN = "${config.programs.google-chrome.finalPackage}/bin/google-chrome";
  };
}
