{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    openvpn
    dotnet-sdk
    terraform
  ];
}
