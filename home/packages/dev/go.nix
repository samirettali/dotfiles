{
  lib,
  pkgs,
  features,
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
      enable = features.go;
      package = pkgs.go_1_26;
      telemetry.mode = "off";
    };
  };

  home.packages = with pkgs;
    lib.optionals features.go [
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

  dotfiles.vscode.extensionIds = lib.optionals features.go [
    "golang.go"
  ];

  programs.vscode.profiles.default = lib.optionalAttrs features.go {
    userSettings = {
      "go.formatTool" = "gofumpt";
      "go.delveConfig" = {
        "showGlobalVariables" = true;
      };
      "go.lintTool" = "golangci-lint-v2"; # TODO: this downloads golangci-lint-v2 in ~/go/bin
      "go.coverOnSingleTest" = true;
      "go.showWelcome" = true;
      "gopls" = {
        "ui.diagnostic.analyses" = {
          "modernize" = true;
          "shadow" = true;
        };
        "ui.semanticTokens" = false;
      };
    };
  };
}
