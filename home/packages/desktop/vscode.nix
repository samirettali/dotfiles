{
  inputs,
  pkgs,
  lib,
  customArgs,
  ...
}: let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  fontSize = 12.5;
in {
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        # supermaven.supermaven
        github.copilot
        github.copilot-chat
        eamodio.gitlens
        golang.go
        jnoortheen.nix-ide
        marketplace.amos402.scope-bar
        marketplace.juanblanco.solidity
        mkhl.direnv
        ms-python.python
        ms-toolsai.jupyter
        rust-lang.rust-analyzer
        vscodevim.vim
        # marketplace.continue.continue
        # marketplace.saoudrizwan.claude-dev
      ];
      keybindings = [];
      userSettings = {
        # TODO: enable copilot agent
        "editor.fontFamily" = customArgs.font.name;
        "editor.fontSize" = fontSize;
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "trailing";
        "editor.lineNumbers" = "relative";
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

        "github.copilot.editor.enableAutoCompletions" = true;

        # Go
        "go.formatTool" = "gofumpt";
        "go.delveConfig" = {
          "showGlobalVariables" = true;
        };
        "go.lintTool" = "revive";
        "go.lintFlags" = [
          "--enable-all"
        ];
        "go.coverOnSingleTest" = true;
        "go.showWelcome" = true;
        "gopls" = {
          "ui.diagnostic.analyses" = {
            "modernize" = true;
          };
          "ui.semanticTokens" = false;
        };

        "nix.formatterPath" = "alejandra";

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
