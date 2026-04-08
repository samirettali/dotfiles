{
  config,
  lib,
  pkgs,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals (features.python == "minimal" || features.python == "full") [
      python314
      uv
    ]
    ++ lib.optionals (features.python == "full") [
      python314Packages.debugpy # used by neovim dap (TODO: remove?)
      basedpyright
      pyrefly
      ty
    ];

  programs = {
    ruff = {
      enable = features.python == "full";
      settings = {};
    };
  };

  dotfiles.vscode.extensionIds =
    lib.optionals (features.python == "full") [
      "ms-python.debugpy"
      "ms-python.python"
      "ms-toolsai.jupyter"
      "ms-toolsai.jupyter-renderers"
    ]
    ++ lib.optionals (features.python == "full" && builtins.elem pkgs.basedpyright config.home.packages) [
      "detachhead.basedpyright"
    ]
    ++ lib.optionals (features.python == "full" && config.programs.ruff.enable) [
      "charliermarsh.ruff"
    ]
    ++ lib.optionals (features.python == "full" && builtins.elem pkgs.ty config.home.packages) [
      "astral-sh.ty"
    ];

  programs.vscode.profiles.default = lib.optionalAttrs (features.python == "full") {
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
