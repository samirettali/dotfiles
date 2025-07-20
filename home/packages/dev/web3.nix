{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    foundry
    go-ethereum
    nur.repos.gabr1sr.vscode-solidity-server
    slither-analyzer
    solc-select
  ];

  programs.vscode.profiles.default = lib.optionals (builtins.elem pkgs.solc-select config.home.packages) {
    extensions = with pkgs.vscode-marketplace; [
      juanblanco.solidity
    ];
    userSettings = {
      "solidity.packageDefaultDependenciesContractsDirectory" = "src";
      "solidity.packageDefaultDependenciesDirectory" = "lib";
      "solidity.compileUsingRemoteVersion" = "v0.8.23";
      "solidity.remappings" = [
        "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/"
        "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/"
      ];
    };
  };
}
