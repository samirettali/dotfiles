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
      "elevenlabs_api_key" = {};
      "exa_api_key" = {};
      "gemini_api_key" = {};
      "genius_access_token" = {};
      "linkding_api_token" = {};
      "openai_api_key" = {};
      "openrouter_api_key" = {};
      # sottotesto's Client Credentials grant, used server-side for search only.
      # The client id is not a secret and stays in the clear in its .envrc.
      "spotify_client_secret" = {};
      # OpenTofu state encryption, one per state bucket rather than per
      # workspace — see the tofu-encryption script.
      "tofu_passphrase_infra" = {};
      "tofu_passphrase_sottocasa" = {};
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
