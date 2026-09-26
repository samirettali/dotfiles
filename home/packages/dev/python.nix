{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals (config.features.python == "minimal" || config.features.python == "full") [
      python314
    ]
    ++ lib.optionals (config.features.python == "full") [
      basedpyright
      pyrefly
      ty
    ];

  programs = {
    uv.enable = config.features.python == "minimal" || config.features.python == "full";
    ruff = {
      enable = config.features.python == "full";
      settings = {};
    };
  };

  dotfiles.neovim.lspServers = lib.optionals (config.features.python == "full") ["basedpyright" "ruff"];
}
