{lib, ...}: {
  programs.difftastic = {
    enable = lib.mkDefault false;
    git.enable = true;
  };
}
