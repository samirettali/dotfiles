{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    dotnet-sdk
    terraform
  ];
}
