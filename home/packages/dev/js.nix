{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    bun
    nodejs
    yarn
    nodePackages.typescript-language-server
    nodePackages.prettier
    prettierd
    # nodePackages.eslint
    eslint_d
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.yarn/bin"
  ];
}
