{
  config,
  pkgs,
  lib,
  ...
}: let
  install = false;
  cursorSettings =
    (builtins.removeAttrs config.programs.vscode.profiles.default.userSettings ["workbench.colorTheme"])
    // {"cursor.composer.shouldChimeAfterChatFinishes" = true;};
in {
  # install cursor if installed is true
  home.packages = with pkgs;
    lib.optionals install [
      code-cursor
    ];

  home.file."Library/Application Support/Cursor/User/settings.json" = {
    enable = install;
    text =
      builtins.toJSON
      cursorSettings;
  };
  home.file."Library/Application Support/Cursor/User/keybindings.json" = {
    enable = install;
    text =
      builtins.toJSON
      config.programs.vscode.profiles.default.keybindings;
  };
}
