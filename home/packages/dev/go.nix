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
}
