{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.zig [
      zig
      zls
    ];
}
