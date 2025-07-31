{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
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

  programs.vscode.profiles.default = lib.optionals config.programs.direnv.enable {
    extensions = with pkgs.vscode-marketplace; [
      mkhl.direnv
    ];
  };
}
