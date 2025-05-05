{pkgs, ...}: {
  programs = {
    go = {
      enable = true;
      telemetry = {
        mode = "off";
      };
    };
  };

  home.packages = with pkgs; [
    air
    delve
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    go-tools
    gotest
    gofumpt
    mockgen
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    revive
  ];
}
