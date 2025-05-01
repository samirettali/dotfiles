{
  pkgs,
  customArgs,
  config,
  ...
}: {
  home.file."Library/Application Support/Cursor/User/settings.json".text =
    builtins.toJSON config.programs.vscode.profiles.default.userSettings;
  home.file."Library/Application Support/Cursor/User/keybindings.json".text =
    builtins.toJSON config.programs.vscode.profiles.default.keybindings;

  programs = {
    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = with pkgs.vscode-marketplace; [
          amos402.scope-bar
          eamodio.gitlens
          franzgollhammer.jb-fleet-dark
          github.vscode-github-actions
          github.vscode-pull-request-github
          golang.go
          jnoortheen.nix-ide
          juanblanco.solidity
          mkhl.direnv
          ms-python.python
          quicktype.quicktype
          rust-lang.rust-analyzer
          supermaven.supermaven
          vscodevim.vim
          # augment.vscode-augment
          # continue.continue
          # google.geminicodeassist
          # saoudrizwan.claude-dev
        ];
        keybindings = [
          {
            "key" = "ctrl+tab";
            "command" = "workbench.action.nextEditor";
          }
          {
            "key" = "ctrl+shift+tab";
            "command" = "workbench.action.previousEditor";
          }
        ];
        userSettings = {
          "editor.fontFamily" = customArgs.font.name;
          "editor.fontSize" = 14;
          "editor.minimap.enabled" = false;
          "editor.formatOnSave" = true;
          "editor.renderWhitespace" = "trailing";
          "editor.lineNumbers" = "relative";
          "editor.wordSeparators" = "/\\()\"'=,.;<>~!@#$%^&*|+=[]{}`?-";
          "editor.inlineSuggest.suppressSuggestions" = true;
          "editor.inlayHints.enabled" = "offUnlessPressed";

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
          "workbench.sideBar.location" = "right";
          "workbench.layoutControl.enabled" = false;
          "workbench.statusBar.visible" = true;
          "workbench.navigationControl.enabled" = false;

          "explorer.confirmDelete" = false;

          "chat.commandCenter.enabled" = false;

          "window.commandCenter" = false;

          "github.copilot.editor.enableAutoCompletions" = true;
          "github.copilot.nextEditSuggestions.enabled" = true;

          "git.confirmSync" = false;

          "terminal.integrated.sendKeybindingsToShell" = true;

          # Go
          "go.formatTool" = "gofumpt";
          "go.delveConfig" = {
            "showGlobalVariables" = true;
          };
          "go.lintTool" = "revive";
          "go.coverOnSingleTest" = true;
          "go.showWelcome" = true;
          "gopls" = {
            "ui.diagnostic.analyses" = {
              "modernize" = true;
            };
            "ui.semanticTokens" = false;
            "analyses" = {
              "shadow" = true;
            };
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
          "gitlens.advanced.blame.customArguments" = [
            "-w"
            "-CCC"
          ];
        };
      };
    };
  };
}
