{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    age
    sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "gemini_api_key" = {};
      # Still here for the `lyrics` command's wrapper in packages/shell/scripts.
      # sottotesto reads its own copy from rbw now; drop this once that wrapper
      # moves too, and not before — the reference is what makes the build fail.
      "genius_access_token" = {};
      "openai_api_key" = {};
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  # The upstream Darwin activation races Home Manager's LaunchAgent reload:
  # bootout is asynchronous, so the immediate bootstrap can fail with EIO.
  home.activation.sops-nix = lib.mkIf pkgs.stdenv.isDarwin (lib.mkForce ''
    PATH=/usr/bin:/bin:/usr/sbin:/sbin ${config.launchd.agents.sops-nix.config.Program}
  '');
}
