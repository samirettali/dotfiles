{
  username,
  homeDirectory,
  stateVersion,
  pkgs,
  nixpkgs,
  profile,
  home-manager,
  ...
}: {
  imports = [
    (import ./packages.nix { inherit pkgs nixpkgs; })
    ./dotfiles.nix
    ./user/zsh.nix
    ./user/fzf.nix
    ./user/git.nix
  ]
  ++ nixpkgs.lib.optionals pkgs.stdenv.isLinux [
    (import ./linux.nix { inherit home-manager pkgs homeDirectory; })
  ];

  home = { inherit username homeDirectory stateVersion; };

  home.sessionVariables = {
    EDITOR = "nvim";
    RIPGREP_CONFIG_PATH = "${homeDirectory}/.ripgreprc";
  };

  programs =  {
    home-manager.enable = true;
  };
}
