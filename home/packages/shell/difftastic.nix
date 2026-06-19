{...}: {
  programs.difftastic = {
    enable = true;
    # Wired into lazygit only (see lazygit.nix); leave plain `git diff` untouched.
    git.enable = false;
  };
}
