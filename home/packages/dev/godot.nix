{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.godot [
      godot_4
    ];
}
