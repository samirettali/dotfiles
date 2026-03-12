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
    ]
    ++ lib.optionals (features.python == "full") [
      python314Packages.debugpy # used by neovim dap (TODO: remove?)
      basedpyright
      pyrefly
      ty
      uv
    ];

  programs = {
    ruff = {
      enable = features.python == "full";
      settings = {};
    };
  };

  programs.vscode.profiles.default = lib.optionalAttrs (features.python == "full") {
    extensions =
      pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version
      [
        "ms-python.debugpy"
        "ms-python.python"
        "ms-toolsai.jupyter"
        "ms-toolsai.jupyter-renderers"
        (
          lib.optionals (builtins.elem pkgs.basedpyright config.home.packages)
          "detachhead.basedpyright"
        )
        # TODO: not available for pre release
        # (
        #   lib.optionals (builtins.elem pkgs.pyrefly config.home.packages)
        #   "meta.pyrefly"
        # )
        (
          lib.optionals config.programs.ruff.enable
          "charliermarsh.ruff"
        )
        (
          lib.optionals (builtins.elem pkgs.ty config.home.packages)
          "astral-sh.ty"
        )
      ];
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
