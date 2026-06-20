{
  config,
  lib,
  ...
}: {
  programs.direnv = {
    enable = lib.mkDefault true;
    config = {
      # https://www.mankier.com/1/direnv.toml
      load_dotenv = false;
      strict_env = true;
      whitelist = {
        # TODO
        prefix = [];
        exact = [];
      };
    };
  };

  dotfiles.vscode.extensionIds = lib.optionals config.programs.direnv.enable [
    "mkhl.direnv"
  ];
}
