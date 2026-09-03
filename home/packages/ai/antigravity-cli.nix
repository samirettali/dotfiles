{
  lib,
  inputs,
  pkgs,
  ...
}: {
  programs.antigravity-cli = {
    enable = lib.mkDefault true;
    enableMcpIntegration = true;
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
    settings = {
      preferredEditor = "neovim";
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
    };
  };
}
