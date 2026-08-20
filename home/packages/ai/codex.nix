{
  lib,
  nurPkgs,
  inputs,
  pkgs,
  config,
  ...
}: {
  programs.codex = {
    enable = lib.mkDefault true;
    package = nurPkgs.codex;
    enableMcpIntegration = true;
    skills = builtins.removeAttrs (import ./coding-agent-skills.nix {inherit inputs pkgs;}) ["native-web-search"];
    settings = {
      projects = {
        "${config.home.homeDirectory}".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/dotfiles".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/herdr".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/homebrew-tap".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/infra".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/nur".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/pulse".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/servers".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/sottomano".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/sottotesto".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/sottovoce".trust_level = "trusted";
        "${config.home.homeDirectory}/dev/spotctl".trust_level = "trusted";
      };
      approval_policy = "never";
      sandbox_mode = "danger-full-access";
    };
  };
}
