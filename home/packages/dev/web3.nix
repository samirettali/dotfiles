{pkgs, ...}: {
  home.packages = with pkgs; [
    foundry
    go-ethereum
    nur.repos.gabr1sr.vscode-solidity-server
    slither-analyzer
    solc-select
  ];
}
