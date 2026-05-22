{
  config,
  vars,
  lib,
  pkgs,
  inputs,
  vscodeExtLib,
  ...
}: let
  vscodePkgs =
    if pkgs.stdenv.isDarwin
    then
      import inputs.nixpkgs-vscode {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }
    else pkgs;

  baseExtensionIds = [
    # DrBlury.protobuf-vsc # TODO: doesn't exist anymore
    "jacobwgillespie.minimal-icons"
    "franzgollhammer.jb-fleet-dark"

    "vadimcn.vscode-lldb"
    "wgsl-analyzer.wgsl-analyzer"
    "vscodevim.vim"
    "eamodio.gitlens"

    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
    "github.copilot-chat"
  ];

  extensionIds = lib.unique (baseExtensionIds ++ config.dotfiles.vscode.extensionIds);

  withExtension = ext: settings:
    lib.optionalAttrs (builtins.elem ext extensionIds) settings;
in {
  options.dotfiles.vscode.extensionIds = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
  };

  config.programs.vscode = {
    enable = lib.mkDefault false;
    package = vscodePkgs.vscode;

    mutableExtensionsDir = false;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      enableMcpIntegration = true;
      extensions = vscodeExtLib.forVscodeVersion config.programs.vscode.package.version extensionIds;
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
}
