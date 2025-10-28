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
    ruff
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
    extensions = with pkgs.vscode-marketplace;
      [
        ms-python.debugpy
        ms-python.python
      ]
      ++ lib.optionals (builtins.elem pkgs.basedpyright config.home.packages) [
        detachhead.basedpyright
      ]
      ++ lib.optionals (builtins.elem pkgs.pyrefly config.home.packages) [
        meta.pyrefly
      ]
      ++ lib.optionals config.programs.ruff.enable [
        charliermarsh.ruff
      ]
      ++ lib.optionals (builtins.elem pkgs.ty config.home.packages) [
        astral-sh.ty
      ];
    userSettings = {
      "files.exclude" = {
        "**/__pycache__" = true;
        "**/.ruff_cache" = true;
      };
    };
  };
}
