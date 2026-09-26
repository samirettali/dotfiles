{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.zig [
      zig
      zls
    ];

  dotfiles.neovim.lspServers = lib.optionals config.features.zig ["zls"];
}
