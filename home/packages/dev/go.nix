{
  pkgs,
  config,
  ...
}: {
  programs = {
    go = {
      enable = true;
      package = pkgs.go_1_24; # TODO: switch to default version when 1.24 is default in nixpkgs
      goPrivate = [
        "github.com/YoungAgency/*" # TODO: set only in work profile
      ];
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

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];
}
