{...}: {
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--ansi"
      "--bind space:jump,jump:accept"
      "--color 16"
      "--height ~30" # use at most 30 lines
      "--info hidden"
      "--reverse"
      "--style minimal"
      # "--bind 'ctrl-o:become(${lib.getExe pkgs.neovim} {})'" # TODO: this doesn't work
    ];
  };
}
