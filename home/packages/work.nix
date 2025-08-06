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

  # TODO: upstream is broken
  ms-dotnettools-csharp-with-roslyn-copilot = pkgs.vscode-marketplace.ms-dotnettools.csharp.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.cacert];

    preFixup =
      oldAttrs.preFixup
      + ''
        # Download and setup Roslyn Copilot
        echo "Setting up Roslyn Copilot..."
        mkdir -p "$out"/share/vscode/extensions/ms-dotnettools.csharp/.roslynCopilot

        export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        ${pkgs.curl}/bin/curl -L "https://roslyn.blob.core.windows.net/releases/Microsoft.VisualStudio.Copilot.Roslyn.LanguageServer-18.0.479-alpha.zip" \
          -o roslyn-copilot.zip

        ${pkgs.unzip}/bin/unzip -q roslyn-copilot.zip -d "$out"/share/vscode/extensions/ms-dotnettools.csharp/.roslynCopilot

        rm roslyn-copilot.zip
        echo "Roslyn Copilot setup complete."
      '';
  });
in {
  home.packages = with pkgs; [
    awscli2
    csharpier
    dotnet-ef
    dotnetPackages
    jetbrains.datagrip
    maven
    mongodb-compass
    nuget
    postman
    roslyn-ls
    slack
    ssm-session-manager-plugin
    stunnel
    terraform
    terraform-ls
    openvpn
    netcoredbg
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
          ms-dotnettools-csharp-with-roslyn-copilot
          ms-dotnettools.vscode-dotnet-runtime
          ms-vsliveshare.vsliveshare
        ];
        userSettings = {
          "csharp.experimental.debug.hotReload" = true;
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
          "csharpier.dev.useCustomPath" = true;
          "csharpier.dev.customPath" = "${pkgs.csharpier}/bin/";
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
