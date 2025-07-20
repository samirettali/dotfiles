{pkgs, ...}: {
  home.packages = with pkgs; [
    basedpyright
    pyrefly
    pyright
    python313
    ruff
    ty
    uv
  ];

  # TODO: handle optionals
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-marketplace; [
      astral-sh.ty
      charliermarsh.ruff
      detachhead.basedpyright
      meta.pyrefly
      ms-python.debugpy
      ms-python.python
    ];
    userSettings = {
      "files.exclude" = {
        "**/__pycache__" = true;
        "**/.ruff_cache" = true;
      };
    };
  };
}
