{
  inputs,
  pkgs,
  customArgs,
  ...
}: let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github
        golang.go
        jnoortheen.nix-ide
        marketplace.amos402.scope-bar
        marketplace.franzgollhammer.jb-fleet-dark
        marketplace.juanblanco.solidity
        mkhl.direnv
        ms-toolsai.jupyter
        rust-lang.rust-analyzer
        vscodevim.vim
        # marketplace.continue.continue
        # marketplace.saoudrizwan.claude-dev
        # ms-python.python
        # supermaven.supermaven
      ];
      keybindings = [];
      userSettings = {
        # TODO: enable copilot agent
        "editor.fontFamily" = customArgs.font.name;
        "editor.fontSize" = customArgs.font.size;
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
        "workbench.colorTheme" = "Fleet Dark";

        "github.copilot.editor.enableAutoCompletions" = true;
        "github.copilot.nextEditSuggestions.enabled" = true;

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
