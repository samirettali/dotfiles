{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    go = {
      enable = true;
      package = pkgs.go_1_26;
      telemetry = {
        mode = "off";
      };
    };
  };

  home.packages = with pkgs;
    lib.optionals config.programs.go.enable [
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

  programs.vscode.profiles.default = lib.optionals config.programs.go.enable {
    extensions = pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version [
      "golang.go"
    ];
    userSettings = {
      "go.formatTool" = "gofumpt";
      "go.delveConfig" = {
        "showGlobalVariables" = true;
      };
      "go.lintTool" = "revive";
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
