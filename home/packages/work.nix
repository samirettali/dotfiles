{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    awscli2
    dotnet-sdk_8
    terraform
    csharp-ls
  ];
}
