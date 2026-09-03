{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  myRepos = import ./repos.nix {inherit config;};
in {
  programs.antigravity-cli = {
    enable = lib.mkDefault true;
    enableMcpIntegration = true;
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
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
