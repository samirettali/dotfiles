{
  inputs,
  pkgs,
  lib,
  customArgs,
  ...
}: let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  fontSize = 13;
in {
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = false;
      extensions =
        (with pkgs.vscode-extensions; [
          eamodio.gitlens
          golang.go
          jnoortheen.nix-ide
          mkhl.direnv
          ms-python.python
          ms-toolsai.jupyter
          rust-lang.rust-analyzer
          supermaven.supermaven
          vscodevim.vim
        ])
        ++ [
          (lib.mkIf pkgs.stdenv.isDarwin marketplace.ms-dotnettools.csharp)
          (lib.mkIf pkgs.stdenv.isDarwin marketplace.ms-dotnettools.csdevkit)
          (lib.mkIf pkgs.stdenv.isDarwin marketplace.ms-dotnettools.vscode-dotnet-runtime)
          marketplace.amos402.scope-bar
          marketplace.juanblanco.solidity
          marketplace.continue.continue
          marketplace.saoudrizwan.claude-dev
        ];
      keybindings = [];
      userSettings = {
        "editor.fontFamily" = customArgs.font.name;
        "editor.fontSize" = fontSize;
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "trailing";
        "editor.wordSeparators" = "/\\()\"'=,.;<>~!@#$%^&*|+=[]{}`?-";
        "editor.inlineSuggest.suppressSuggestions" = true;

        "diffEditor.ignoreTrimWhitespace" = false;

        "files.exclude" = {
          "**/.classpath" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.factorypath" = true;
        };

        "telemetry.telemetryLevel" = "off";

        "workbench.tree.indent" = 24;
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
        "workbench.startupEditor" = "none";

        "github.copilot.editor.enableAutoCompletions" = false;

        # Go
        "go.formatTool" = "gofumpt";
        "go.delveConfig" = {
          "showGlobalVariables" = true;
        };
        "go.lintTool" = "golangci-lint";
        "go.lintFlags" = [
          "--enable-all"
        ];
        "go.coverOnSingleTest" = true;
        "go.showWelcome" = true;
        "gopls" = {
          "ui.semanticTokens" = false;
        };

        "gitlens.showWelcomeOnInstall" = false;

        "vim.handleKeys" = {
          "<C-p>" = false;
        };

        "solidity.packageDefaultDependenciesContractsDirectory" = "src";
        "solidity.packageDefaultDependenciesDirectory" = "lib";
        "solidity.compileUsingRemoteVersion" = "v0.8.23";
        "solidity.remappings" = [
          "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/"
          "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/"
        ];
      };
    };
  };
}
