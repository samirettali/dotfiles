{
  config,
  customArgs,
  lib,
  pkgs,
  ...
}: let
  cursorSettings = {
    "cursor.composer.shouldChimeAfterChatFinishes" = true;
  };

  withExtension = ext: settings:
    lib.optionalAttrs (builtins.elem ext config.programs.vscode.profiles.default.extensions) settings;

  settings = lib.mkMerge [
    {
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
        "**/*.Designer.cs" = true;
      };

      "telemetry.telemetryLevel" = "off";

      "workbench.tree.indent" = 24;
      "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      "workbench.startupEditor" = "none";
      "workbench.sideBar.location" = "right";
      "workbench.layoutControl.enabled" = false;
      "workbench.statusBar.visible" = true;
      "workbench.navigationControl.enabled" = false;

      "git.confirmSync" = false;
      "git.openRepositoryInParentFolders" = "always";

      "debug.onTaskErrors" = "showErrors";

      "explorer.confirmDelete" = false;

      "window.commandCenter" = false;

      "chat.commandCenter.enabled" = false;

      "search.useIgnoreFiles" = false;
      "search.exclude" = {
        "**/node_modules" = true;
        "**/.venv" = true;
      };

      "terminal.integrated.sendKeybindingsToShell" = true;
    }
    # (lib.mkIf isVSCode {
    #   "workbench.colorTheme" = "Fleet Sphere";
    # })
    (withExtension pkgs.vscode-marketplace.vscodevim.vim {
      "vim.handleKeys" = {
        "<C-p>" = false;
      };
    })
    (withExtension pkgs.vscode-marketplace.google.geminicodeassist {
      "geminicodeassist.enableTelemetry" = false;
      "geminicodeassist.customCommands" = {
        "add-comment" = "comment the code";
        "refactor" = "refactor the code";
      };
      "geminicodeassist.rules" = ''
        Never ask "Would you like me to make this change for you?" Just do it.
        In Python projects, use `uv` to manage dependencies.
        In JavaScript/TypeScript projects, use `bun` to manage dependencies.
      '';
      "geminicodeassist.inlineSuggestions.enableAuto" = false;
    })
    (withExtension pkgs.vscode-marketplace.juanblanco.solidity {
      "solidity.packageDefaultDependenciesContractsDirectory" = "src";
      "solidity.packageDefaultDependenciesDirectory" = "lib";
      "solidity.compileUsingRemoteVersion" = "v0.8.23";
      "solidity.remappings" = [
        "@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/"
        "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/"
      ];
    })
    (withExtension pkgs.vscode-marketplace.golang.go {
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
    })
    (withExtension pkgs.vscode-marketplace.github.copilot {
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = true;
        "markdown" = true;
      };
      "github.copilot.nextEditSuggestions.enabled" = true;
    })
    (withExtension pkgs.vscode-marketplace.jnoortheen.nix-ide {
      "nix.formatterPath" = "alejandra";
    })
    (withExtension pkgs.vscode-marketplace.eamodio.gitlens {
      "gitlens.advanced.blame.customArguments" = [
        "-w"
        "-CCC"
      ];
    })
  ];
in {
  home.file."Library/Application Support/Cursor/User/settings.json".text =
    builtins.toJSON (config.programs.vscode.profiles.default.userSettings // cursorSettings);
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
          google.geminicodeassist
          jnoortheen.nix-ide
          juanblanco.solidity
          mkhl.direnv

          ms-python.python
          ms-python.debugpy
          charliermarsh.ruff

          quicktype.quicktype
          rust-lang.rust-analyzer
          saoudrizwan.claude-dev
          sourcegraph.amp
          supermaven.supermaven
          vscodevim.vim
          wgsl-analyzer.wgsl-analyzer
          # vadimcn.vscode-lldb # TODO: build is broken
          # augment.vscode-augment
          # continue.continue
          # github.copilot
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
        userSettings = settings;
      };
    };
  };
}
