{pkgs, ...}: {
  home.programs = {
    go = {
      enable = true;
      goPrivate = "github.com/YoungAgency/*"; # TODO: set only in work profile
      telemetry = {
        mode = "off";
      };
    };
  };

  home.pacakges = with pkgs; [
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
