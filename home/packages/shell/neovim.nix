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
      # TODO: lsp formatting and linters
      # yaml-language-server
      # buf
      # taplo
      # codespell
      # yamlfmt
      # zizmor
      # wgsl-analyzer
    ];
  };
}
