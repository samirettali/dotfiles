{pkgs, ...}: {
  home.packages = with pkgs; [
    foundry-bin
    solc-select
    # slither-analyzer
    go-ethereum
    nur.repos.gabr1sr.vscode-solidity-server
  ];
}
