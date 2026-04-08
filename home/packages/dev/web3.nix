{
  config,
  lib,
  pkgs,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals features.web3 [
      foundry
      go-ethereum
      slither-analyzer
      solc-select
      vscode-solidity-server
    ];

  dotfiles.vscode.extensionIds = lib.optionals features.web3 [
    "juanblanco.solidity"
  ];

  programs.vscode.profiles.default = lib.optionalAttrs features.web3 {
    userSettings = {
      "solidity.packageDefaultDependenciesContractsDirectory" = "src";
      "solidity.packageDefaultDependenciesDirectory" = "lib";
      "solidity.compileUsingRemoteVersion" = "v0.8.23"; # TODO: should this be removed?
      "solidity.remappings" = [
        "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/"
        "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/"
      ];
    };
  };
}
