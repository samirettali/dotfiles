{pkgs, ...}: {
  home.pacakges = with pkgs; [
    python312
    pipenv
    pyenv
    pyright
    isort
    black
    uv
  ];
}
