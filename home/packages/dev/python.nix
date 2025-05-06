{pkgs, ...}: {
  home.packages = with pkgs; [
    basedpyright
    pyright
    python312
    ruff
    uv
  ];
}
