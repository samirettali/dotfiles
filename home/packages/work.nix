{
  config,
  lib,
  pkgs,
  ...
}: let
  dotnetPackages = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_6_0-bin
      sdk_8_0-bin
      sdk_9_0-bin
    ];
in {
  home.packages = with pkgs; [
    awscli2
    csharpier
    dotnet-ef
    dotnetPackages
    jetbrains.datagrip
    maven
    mongodb-compass
    netcoredbg
    nuget
    openvpn
    postman
    roslyn-ls
    slack
    ssm-session-manager-plugin
    stunnel
    terraform
    terraform-ls
    mongosh
  ];

  programs = {
    go.env.GOPRIVATE = [
      "github.com/YoungAgency/*"
    ];

    vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-marketplace; [
          hashicorp.terraform
          ms-vsliveshare.vsliveshare

          # csharpier.csharpier-vscode
          pkgs.vscode-extensions.ms-dotnettools.csharp
          pkgs.vscode-extensions.ms-dotnettools.csdevkit
          pkgs.vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
        ];
        userSettings = {
          "csharp.experimental.debug.hotReload" = true;
          "csharp.debug.justMyCode" = false;
          "dotnetAcquisitionExtension.enableTelemetry" = false;
          "dotnetAcquisitionExtension.sharedExistingDotnetPath" = "${lib.getExe' dotnetPackages "dotnet"}";
          "csharp.debug.symbolOptions.cachePath" = "${config.home.homeDirectory}/.cache/vscode-csharp-ls";
          "csharp.inlayHints.enableInlayHintsForTypes" = true;
          "csharp.inlayHints.enableInlayHintsForImplicitObjectCreation" = true;
          "csharp.inlayHints.enableInlayHintsForImplicitVariableTypes" = true;
          "csharp.inlayHints.enableInlayHintsForLambdaParameterTypes" = true;
          "dotnet.inlayHints.enableInlayHintsForIndexerParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForLiteralParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForObjectCreationParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForOtherParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForParameters" = true;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatDifferOnlyBySuffix" = false;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatMatchArgumentName" = false;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatMatchMethodIntent" = false;
          # "dotnet.formatting.organizeImportsOnFormat" = true; # TODO: csharpier?
          # "csharp.debug.expressionEvaluationOptions.showRawValues" = false;
          "omnisharp.enableDecompilationSupport" = true;
          # "[csharp]" = {
          #   "editor.defaultFormatter" = "csharpier.csharpier-vscode";
          # };
          # "csharpier.dev.useCustomPath" = true;
          # "csharpier.dev.customPath" = "${pkgs.csharpier}/bin/";
        };
      };
    };

    granted = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetPackages}/share/dotnet"; # TODO: check if should add /share/dotnet/
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION = "1";
  };
}
