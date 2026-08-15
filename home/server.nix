{
  imports = [
    ./dotfiles.nix
    ./options.nix
    ./packages/dev/c.nix
    ./packages/dev/go.nix
    ./packages/dev/js.nix
    ./packages/dev/python.nix
    ./packages/shell
    ./packages/desktop/google-chrome.nix
  ];

  dotfiles.programs = {
    ansible.enable = false;
    git-sync.enable = false;
  };

  programs.fish.enable = false;
}
