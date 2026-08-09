{
  config,
  inputs,
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
      # OpenTofu state encryption, one per state bucket rather than per
      # workspace — see the tofu-encryption script.
      "tofu_passphrase_infra" = {};
      "tofu_passphrase_sottocasa" = {};
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
