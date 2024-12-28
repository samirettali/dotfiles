{pkgs, ...}: {
  home.sessionVariables = {
    CLICOLOR = "1";
  };

  programs = {
    zsh = {
      initExtra = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      shellAliases = {
        ls = "/opt/homebrew/bin/gls --color=auto --group-directories-first";
      };
    };

    fish = {
      shellAliases = {
        ls = "/opt/homebrew/bin/gls --color=auto --group-directories-first";
      };
    };

    gpg.enable = true;
  };

  home.packages = with pkgs; [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];
}
