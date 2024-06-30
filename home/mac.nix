{ ...
}: {
  home.sessionVariables = {
    CLICOLOR = "1";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };


  programs = {
    zsh = {
      initExtra = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      shellAliases = {
        ls = "/opt/homebrew/bin/gls --color=auto --group-directories-first";
        assume = "source assume";
      };
    };

    gpg.enable = true;
  };
}
