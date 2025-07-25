{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    bun
    eslint_d
    nodePackages.eslint
    nodePackages.js-beautify
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs
    prettierd
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.yarn/bin"
  ];
}
