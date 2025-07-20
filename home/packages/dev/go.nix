{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    go = {
      enable = true;
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
      revive
    ];

  programs.vscode.profiles.default = lib.optionals config.programs.go.enable {
    extensions = with pkgs.vscode-marketplace; [
      golang.go
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
        };
        "ui.semanticTokens" = false;
        "analyses" = {
          "shadow" = true;
        };
      };
    };
  };
}
