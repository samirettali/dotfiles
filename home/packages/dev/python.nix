{pkgs, ...}: {
  home.packages = with pkgs; [
    basedpyright
    pyright
    # python313 # TODO: this is installed along with llm and somehow there's a conflict
    ruff
    uv
  ];
}
