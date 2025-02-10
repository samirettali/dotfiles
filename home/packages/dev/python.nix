{pkgs, ...}: {
  home.packages = with pkgs; [
    python312
    pipenv
    pyenv
    pyright
    isort
    black
    uv
  ];
}
