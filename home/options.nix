{lib, ...}: {
  options = {
    dotfiles.vscode.extensionIds = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
    };

    features = {
      rust = lib.mkEnableOption "Rust tooling";
      dart = lib.mkEnableOption "Dart tooling";
      security = lib.mkEnableOption "security tooling";
      web3 = lib.mkEnableOption "Web3 tooling";
      zig = lib.mkEnableOption "Zig tooling";
      java = lib.mkEnableOption "Java tooling";
      js = lib.mkOption {
        type = lib.types.enum [false "minimal" "full"];
        default = false;
      };
      c = lib.mkEnableOption "C tooling";
      go = lib.mkEnableOption "Go tooling";
      python = lib.mkOption {
        type = lib.types.enum [false "minimal" "full"];
        default = false;
      };
    };
  };
}
