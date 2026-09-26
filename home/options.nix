{lib, ...}: {
  options = {
    dotfiles = {
      programs = {
        ansible.enable = lib.mkEnableOption "Ansible tooling";
        git-sync.enable = lib.mkEnableOption "git-sync";
      };

      # The module that installs a language server names it here, so Neovim
      # enables only the servers this machine has.
      neovim.lspServers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };

    features = {
      rust = lib.mkEnableOption "Rust tooling";
      security = lib.mkEnableOption "security tooling";
      android = lib.mkEnableOption "Android device tooling";
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
      godot = lib.mkEnableOption "Godot engine";
      python = lib.mkOption {
        type = lib.types.enum [false "minimal" "full"];
        default = false;
      };
    };
  };
}
