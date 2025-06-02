{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      # "espanso_matches/evm" = {};
      # "espanso_matches/alt" = {};
      # "espanso_matches/hot" = {};
      # "espanso_matches/svm" = {};
      # "espanso_matches/em" = {};
      # "espanso_matches/wem" = {};
      # "espanso_matches/pri" = {};
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
