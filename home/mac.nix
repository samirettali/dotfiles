{ ... }: {
  home.sessionVariables = {
    CLICOLOR = "1";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  programs.gpg.enable = true;
}
