{
  pkgs,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals features.zig [
      zig
      zls
    ];
}
