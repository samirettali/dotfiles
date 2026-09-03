{
  lib,
  nurPkgs,
  inputs,
  pkgs,
  config,
  ...
}: let
  myRepos = import ./repos.nix {inherit config;};
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
    };
  };
}
