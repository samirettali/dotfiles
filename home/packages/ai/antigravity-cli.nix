{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  myRepos = import ./repos.nix {inherit config;};
  guardHook = "${config.home.homeDirectory}/.gemini/hooks/guard-read.py";
in {
  # The module has no hooks option; agy reads ~/.gemini/config/hooks.json on
  # its own. Event and tool names come from the 1.1.24 binary (`PreToolUse`,
  # `view_file`, `read_file`, `run_command`); `force` replaces the empty file
  # agy creates at first launch.
  home.file.".gemini/hooks/guard-read.py".source = ./guard-read.py;
  home.file.".gemini/config/hooks.json" = {
    force = true;
    text = builtins.toJSON {
      hooks.PreToolUse = [
        {
          matcher = "view_file|read_file|run_command";
          hooks = [
            {
              type = "command";
              command = "python3 '${guardHook}'";
              timeout = 10;
            }
          ];
        }
      ];
    };
  };

  programs.antigravity-cli = {
    enable = lib.mkDefault true;
    enableMcpIntegration = true;
    skills = import ./coding-agent-skills.nix {inherit inputs pkgs;};
    settings = {
      preferredEditor = "neovim";
      allowNonWorkspaceAccess = true;
      toolPermission = "always-proceed";
      vimMode = true;
      previewFeatures = true;
      checkpointing = {
        enabled = true;
      };
      hideTips = false;
      hideBanner = false;
      usageStatisticsEnabled = false;
      telemetry = {
        enabled = false;
      };
      contextFileName = "AGENTS.md";
      selectedAuthType = "oauth-personal";
      trustedWorkspaces = [config.home.homeDirectory] ++ myRepos;
    };
  };
}
