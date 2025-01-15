{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    maven
    omnisharp-roslyn
    slack
    terraform
    terraform-ls

    (with dotnetCorePackages;
      combinePackages [
        sdk_6_0
        sdk_8_0
      ])
  ];

  programs.zsh.shellAliases = {
    assume = "source assume";
  };

  programs.granted = {
    enable = true;
  };

  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION = "1";
  };
}
