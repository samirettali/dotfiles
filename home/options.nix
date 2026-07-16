{lib, ...}: {
  options = {
    dotfiles = {
      programs = {
        ansible.enable = lib.mkEnableOption "Ansible tooling";
        git-sync.enable = lib.mkEnableOption "git-sync";
      };

      vscode.extensionIds = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
      };

      agentsMemory.extra = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Host-specific text appended to the global agent memory files.";
      };
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
      c = lib.mkOption {
        type = lib.types.enum [false "minimal" "full"];
        default = false;
      };
      go = lib.mkEnableOption "Go tooling";
      python = lib.mkOption {
        type = lib.types.enum [false "minimal" "full"];
        default = false;
      };
    };
  };
}
