{ ... }: {
  home.sessionVariables = {
    CLICOLOR = "1";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  programs.gpg.enable = true;

  programs = {
    zsh = {
      shellAliases = {
        # ugly fix for MacOS
        ls = "/opt/homebrew/bin/gls --color=auto --group-directories-first";
      };
    };
  };
}
