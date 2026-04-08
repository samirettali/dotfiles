{
  config,
  lib,
  pkgs,
  features,
  ...
}: {
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
      gotools
      mockgen
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      oapi-codegen
      revive
      (go-migrate.overrideAttrs
        (oldAttrs: {
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
