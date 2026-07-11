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
      python314Packages.debugpy # used by neovim dap (TODO: remove?)
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

  dotfiles.vscode.extensionIds =
    lib.optionals (config.features.python == "full") [
      "ms-python.debugpy"
      "ms-python.python"
      "ms-toolsai.jupyter"
      "ms-toolsai.jupyter-renderers"
    ]
    ++ lib.optionals (config.features.python == "full" && builtins.elem pkgs.basedpyright config.home.packages) [
      "detachhead.basedpyright"
    ]
    ++ lib.optionals (config.features.python == "full" && config.programs.ruff.enable) [
      "charliermarsh.ruff"
    ]
    ++ lib.optionals (config.features.python == "full" && builtins.elem pkgs.ty config.home.packages) [
      "astral-sh.ty"
    ];

  programs.vscode.profiles.default = lib.optionalAttrs (config.features.python == "full") {
    userSettings = {
      "files.exclude" =
        {
          "**/__pycache__" = true;
        }
        // lib.optionalAttrs config.programs.ruff.enable {
          "**/.ruff_cache" = true;
        };
    };
  };
}
