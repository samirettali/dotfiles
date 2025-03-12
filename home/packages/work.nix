{
  pkgs,
  config,
  ...
}: let
  marketplace = pkgs.vscode-marketplace;
  dotnetPackages = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_6_0-bin
      sdk_8_0-bin
      sdk_9_0-bin
    ];
  vscode-dotnet-runtime-fixed = marketplace.ms-dotnettools.vscode-dotnet-runtime.overrideAttrs (oldAttrs: {
    postPatch = ""; # TODO: remove, the postPatch step is broken upstream
  });
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
    dotnetPackages
  ];

  programs = {
    go.goPrivate = [
      "github.com/YoungAgency/*"
    ];

    vscode = {
      extensions = [
        marketplace.ms-dotnettools.csdevkit
        marketplace.ms-dotnettools.csharp
        vscode-dotnet-runtime-fixed
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
      };
    };

    zsh.shellAliases = {
      assume = "source assume";
    };

    granted = {
      enable = true;
    };
  };

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnetPackages}";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SYSTEM_CONSOLE_ALLOW_ANSI_COLOR_REDIRECTION = "1";
  };
}
