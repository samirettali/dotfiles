{
  pkgs,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals features.dart [
      # dart
      flutter
    ];
}
