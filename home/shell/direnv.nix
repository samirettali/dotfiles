{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = false;
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

  programs.vscode.profiles.default.extensions =
    lib.mkIf config.programs.direnv.enable
    [
      pkgs.vscode-marketplace.mkhl.direnv
    ];
}
