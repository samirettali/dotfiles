{ username
, homeDirectory
, stateVersion
, pkgs
, nixpkgs
, profile
, home-manager
, ...
}: {
  imports = [
    (import ./packages.nix { inherit pkgs nixpkgs; })
    ./dotfiles.nix
    ./user/zsh.nix
    ./user/fzf.nix
    ./user/git.nix
    ./programs/ripgrep.nix
    (import ./programs/tmux.nix { inherit pkgs homeDirectory; })
  ]
  ++ nixpkgs.lib.optionals pkgs.stdenv.isLinux [
    (import ./linux.nix { inherit home-manager pkgs homeDirectory nixpkgs; })
  ];

  home = { inherit username homeDirectory stateVersion; };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs = {
    home-manager.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "ansi";
      };
      extraPackages = with pkgs.bat-extras; [ batgrep ];
    };
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-audit
        exts.pass-audit
        exts.pass-genphrase
        exts.pass-otp
        exts.pass-update
      ]);
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
