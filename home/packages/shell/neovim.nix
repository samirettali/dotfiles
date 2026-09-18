{
  lib,
  pkgs,
  neovimPackage,
  ...
}: {
  programs.neovim = {
    enable = lib.mkDefault true;
    package = neovimPackage;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      copilot-language-server # for "copilotlsp" neovim plugin
      bash-language-server
      shellcheck
      shfmt
      harper
      yaml-language-server
      vscode-langservers-extracted # vscode-json-language-server
      # TODO: lsp formatting and linters
      # codespell
      # yamlfmt
      # zizmor
      # wgsl-analyzer
    ];
  };

}
