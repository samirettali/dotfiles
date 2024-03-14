{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    awscli2
    terraform
    csharp-ls

    (with dotnetCorePackages; combinePackages [
      sdk_6_0
      sdk_8_0
    ])
  ];
}
