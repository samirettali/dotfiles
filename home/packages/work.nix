{
  lib,
  pkgs,
  inputs,
  ...
}: let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
  home.packages = with pkgs; [
    awscli2
    csharpier
    maven
    roslyn-ls
    slack
    ssm-session-manager-plugin
    terraform
    terraform-ls

    (with dotnetCorePackages;
      combinePackages [
        sdk_6_0
        sdk_8_0
      ])
  ];

  programs = {
    vscode = {
      # extensions = [
      #   marketplace.ms-dotnettools.csharp
      #   marketplace.ms-dotnettools.csdevkit
      #   marketplace.ms-dotnettools.vscode-dotnet-runtime
      # ];
    };

    zsh.shellAliases = {
      assume = "source assume";
    };

    granted = {
      enable = true;
    };
  };

  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION = "1";
  };
}
