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
}
