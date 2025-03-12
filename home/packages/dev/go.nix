{pkgs, ...}: {
  programs = {
    go = {
      enable = true;
      package = pkgs.go_1_24; # TODO: switch to default version when 1.24 is default in nixpkgs
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
    gotest
    gofumpt
    mockgen
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    revive
  ];
}
