{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    bun
    eslint_d
    nodePackages.eslint
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs
    pnpm
    prettierd
    yarn
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.yarn/bin"
  ];
}
