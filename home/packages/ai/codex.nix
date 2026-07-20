{
  lib,
  nurPkgs,
  inputs,
  pkgs,
  ...
}: {
  programs.codex = {
    enable = lib.mkDefault true;
    package = nurPkgs.codex;
    enableMcpIntegration = true;
    settings.mcp_servers.elevenlabs = {
      command = "uvx";
      args = ["elevenlabs-mcp"];
      enabled = false;
    };
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
  };
}
