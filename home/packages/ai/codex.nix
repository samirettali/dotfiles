{
  lib,
  nurPkgs,
  inputs,
  pkgs,
  config,
  ...
}: let
  myRepos = import ./repos.nix {inherit config;};
  codexHome = "${config.home.homeDirectory}/.codex";
  managedConfig = "${codexHome}/config.toml.nix";
  writableConfig = "${codexHome}/config.toml";
in {
  programs.codex = {
    enable = lib.mkDefault true;
    package = nurPkgs.codex;
    enableMcpIntegration = true;
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
    settings = {
      projects =
        {
          "${config.home.homeDirectory}".trust_level = "trusted";
        }
        // lib.genAttrs myRepos (_: {
          trust_level = "trusted";
        });
      approval_policy = "never";
      sandbox_mode = "danger-full-access";
      hooks.state."${codexHome}/hooks.json:session_start:0:0" = {
        trusted_hash = "sha256:4167dc7691a7b44db36e4b20a0cf5ffae824133f8bfcd02cfa15b2caae716a76";
        enabled = true;
      };
    };
  };

  # Codex updates hook state in config.toml, so keep the generated source separate.
  home.file.".codex/config.toml" = {
    target = ".codex/config.toml.nix";
    onChange = ''
      tmp=${lib.escapeShellArg "${writableConfig}.tmp"}
      ${pkgs.coreutils}/bin/install -m 0600 ${lib.escapeShellArg managedConfig} "$tmp"
      ${pkgs.coreutils}/bin/mv -f "$tmp" ${lib.escapeShellArg writableConfig}
    '';
  };
}
