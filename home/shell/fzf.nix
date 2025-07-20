{...}: {
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--ansi"
      "--bind space:jump,jump:accept"
      "--color 16"
      "--height ~10" # use at most 10 lines
      "--info hidden"
      "--reverse"
      "--style minimal"
    ];
    # fzf --preview="bat --color=always {}"
    # fzf --bind "enter:become(nvim {})"
  };
}
