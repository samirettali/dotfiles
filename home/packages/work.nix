{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    terraform
    csharp-ls
    dbeaver-bin
    maven

    (with dotnetCorePackages;
      combinePackages [
        sdk_6_0
        sdk_8_0
      ])
  ];

  programs.zsh.shellAliases = {
    assume = "source assume";
  };

  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
}
