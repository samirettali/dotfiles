{
  pkgs,
  config,
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
    maven
    nuget
    roslyn-ls
    slack
    ssm-session-manager-plugin
    terraform
    terraform-ls
  ];

  programs = {
    go.goPrivate = [
      "github.com/YoungAgency/*"
    ];

    vscode = {
      profiles.default = {
        extensions = with pkgs.vscode-marketplace; [
          csharpier.csharpier-vscode
          hashicorp.terraform
          ms-dotnettools.csdevkit
          ms-dotnettools.csharp
          ms-dotnettools.vscode-dotnet-runtime
          ms-vsliveshare.vsliveshare
        ];
        userSettings = {
          "csharp.experimental.debug.hotReload" = true;
          "dotnetAcquisitionExtension.enableTelemetry" = false;
          "dotnetAcquisitionExtension.sharedExistingDotnetPath" = "${dotnetPackages}/bin/dotnet";
          "csharp.debug.symbolOptions.cachePath" = "${config.home.homeDirectory}/.cache/vscode-csharp-ls";
          "csharp.inlayHints.enableInlayHintsForTypes" = true;
          "csharp.inlayHints.enableInlayHintsForImplicitObjectCreation" = true;
          "csharp.inlayHints.enableInlayHintsForImplicitVariableTypes" = true;
          "csharp.inlayHints.enableInlayHintsForLambdaParameterTypes" = true;
          "dotnet.inlayHints.enableInlayHintsForIndexerParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForLiteralParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForObjectCreationParameters" = false;
          "dotnet.inlayHints.enableInlayHintsForOtherParameters" = true;
          "dotnet.inlayHints.enableInlayHintsForParameters" = true;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatDifferOnlyBySuffix" = false;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatMatchArgumentName" = false;
          "dotnet.inlayHints.suppressInlayHintsForParametersThatMatchMethodIntent" = false;
          "dotnet.formatting.organizeImportsOnFormat" = true;
          "csharp.debug.expressionEvaluationOptions.showRawValues" = true;
          "omnisharp.enableDecompilationSupport" = true;
          "[csharp]" = {
            "editor.defaultFormatter" = "csharpier.csharpier-vscode";
          };
          "csharpier.dev.useCustomPath" = true;
          "csharpier.dev.customPath" = "${pkgs.csharpier}/bin";
          "gopls" = {
            "analyses" = {
              "composites" = false;
            };
          };
        };
      };
    };

    zsh.shellAliases = {
      assume = "source assume";
    };

    granted = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetPackages}/share/dotnet"; # TODO: check if should add /share/dotnet/
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION = "1";
  };
}
