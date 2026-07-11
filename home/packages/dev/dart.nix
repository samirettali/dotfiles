{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.dart [
      # dart
      flutter
    ];
}
