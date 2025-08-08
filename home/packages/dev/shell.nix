{pkgs, ...}: {
  home.packages = with pkgs; [
    copilot-language-server # for "copilotlsp" neovim plugin
    bash-language-server
    shellcheck
    shfmt
  ];
}
