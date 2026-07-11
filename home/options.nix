{lib, ...}: {
  options.dotfiles.vscode.extensionIds = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
  };
}
