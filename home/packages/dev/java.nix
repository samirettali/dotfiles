{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    java.enable = config.features.java;
  };

  home.packages = with pkgs;
    lib.optionals config.features.java [
      jdt-language-server
    ];

  dotfiles.neovim.lspServers = lib.optionals config.features.java ["jdtls"];
}
