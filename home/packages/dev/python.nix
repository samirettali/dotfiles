{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python313Packages.debugpy # used by neovim dap
    basedpyright
    pyrefly
    python314
    ty
    uv
  ];

  programs = {
    ruff = {
      enable = true;
      settings = {};
    };
  };

  programs.vscode.profiles.default = {
    extensions =
      pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version
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
