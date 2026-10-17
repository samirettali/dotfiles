{
  imports = [
    ./dotfiles.nix
    ./linux-shell.nix
    ./options.nix
    ./packages/dev/c.nix
    ./packages/dev/go.nix
    ./packages/dev/headless-browser.nix
    ./packages/dev/js.nix
    ./packages/dev/python.nix
    ./packages/shell
  ];

  dotfiles.programs = {
    ansible.enable = false;
    git-sync.enable = false;
  };

  programs.fish.enable = false;

  home.sessionVariables.KIMI_MEMBERSHIP_LEVEL = "moderato";
}
