{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.android [
      android-tools # adb, fastboot
      maestro # UI automation by text/id instead of coordinates
    ];

  # Maestro phones home on every invocation unless this is set.
  home.sessionVariables = lib.mkIf config.features.android {
    MAESTRO_CLI_NO_ANALYTICS = "1";
  };
}
