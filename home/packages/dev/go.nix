{
  config,
  lib,
  pkgs,
  ...
}: let
  gotoolsWithoutModernize = pkgs.symlinkJoin {
    name = "gotools-without-modernize";
    paths = [pkgs.gotools];
    postBuild = ''
      rm -f "$out/bin/modernize"
    '';
  };
in {
  programs = {
    go = {
      enable = config.features.go;
      package = pkgs.go_1_27;
      telemetry.mode = "off";
    };
  };

  home.packages = with pkgs;
    lib.optionals config.features.go [
      air
      delve
      go-tools
      gofumpt
      golangci-lint
      golangci-lint-langserver
      gopls
      gotest
      gotoolsWithoutModernize # TODO: https://github.com/NixOS/nixpkgs/issues/509480
      mockgen
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      oapi-codegen
      revive
      (go-migrate.overrideAttrs
        (_oldAttrs: {
          tags = ["postgres"];
        }))
    ];

  dotfiles.neovim.lspServers = lib.optionals config.features.go ["gopls" "golangci_lint_ls"];
}
