{pkgs, ...}: {
  home.packages = with pkgs; [
    basedpyright
    pyrefly
    pyright
    # python313 # TODO: this is installed along with llm and somehow there's a conflict
    ruff
    ty
    uv
  ];
}
