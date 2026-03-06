{
  config,
  vars,
  lib,
  pkgs,
  ...
}: let
  extensions = [
    # DrBlury.protobuf-vsc # TODO: doesn't exist anymore
    "jacobwgillespie.minimal-icons"
    "franzgollhammer.jb-fleet-dark"

    "vadimcn.vscode-lldb"
    "wgsl-analyzer.wgsl-analyzer"
    "vscodevim.vim"
    "eamodio.gitlens"

    "kilocode.Kilo-Code"

    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
    "github.copilot-chat"
  ];

  withExtension = ext: settings:
    lib.optionalAttrs (builtins.elem ext extensions) settings;
in {
  programs = {
    vscode = {
      enable = true;

      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        enableMcpIntegration = true;
        extensions = pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version extensions;
        keybindings = [
          {
            "key" = "ctrl+tab";
            "command" = "workbench.action.nextEditor";
          }
          {
            "key" = "ctrl+shift+tab";
            "command" = "workbench.action.previousEditor";
          }
          {
            "key" = "ctrl+g";
            "command" = "workbench.action.findInFiles";
          }
          {
            "key" = "ctrl+f";
            "command" = "workbench.action.quickOpen";
          }
        ];
        userSettings = lib.mkMerge [
          {
            "editor.fontFamily" = vars.font.name;
            "editor.fontSize" = vars.font.size;
            "editor.minimap.enabled" = false;
            "editor.formatOnSave" = true;
            "editor.renderWhitespace" = "trailing";
            "editor.lineNumbers" = "relative";
            "editor.wordSeparators" = "/\\()\"'=,.;<>~!@#$%^&*|+=[]{}`?-";
            "editor.inlineSuggest.suppressSuggestions" = true;
            "editor.inlayHints.enabled" = "offUnlessPressed";

            "terminal.integrated.fontSize" = vars.font.size;

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

            "chat.commandCenter.enabled" = true;

            "search.useIgnoreFiles" = false;
            "search.exclude" = {
              "**/node_modules" = true;
              "**/.venv" = true;
            };

            "terminal.integrated.sendKeybindingsToShell" = true;

            "extensions.autoUpdate" = false;
          }
          (withExtension "github.copilot-chat" {
            "chat.extensionUnification.enabled" = true;
            "chat.useAgentSkills" = true;
            "chat.instructionsFilesLocations" = {
              ".github/instructions" = true;
              ".claude/rules" = true;
            };
            "github.copilot.enable" = {
              "*" = true;
              "plaintext" = true;
              "markdown" = true;
            };
            "github.copilot.advanced" = {
              "useLanguageServer" = true;
            };
            "github.copilot.nextEditSuggestions.enabled" = true;
          })
          (withExtension "jacobwgillespie.minimal-icons" {
            "workbench.iconTheme" = "minimal-icons-without-explorer-arrows";
          })
          (withExtension "franzgollhammer.jb-fleet-dark" {
            "workbench.colorTheme" = "Sphere";
          })
          (withExtension "vscodevim.vim" {
            "vim.handleKeys" = {
              "<C-p>" = false;
            };
          })
          (withExtension "eamodio.gitlens" {
            "gitlens.advanced.blame.customArguments" = [
              "-w"
              "-CCC"
            ];
          })
        ];
      };
    };
  };
}
