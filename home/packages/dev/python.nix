{pkgs, ...}: {
  home.packages = with pkgs; [
    basedpyright
    pipenv
    pyenv
    pyright
    python312
    ruff
    uv
  ];
}
