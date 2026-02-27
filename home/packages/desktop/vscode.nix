{
  config,
  customArgs,
  lib,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  throwSystem = throw "Unsupported system: ${system}";
  source =
    {
      aarch64-darwin = {
        os = "darwin-arm64";
        sha256 = "sha256-YKSCppJYA9IvTE+MYOikzWXoA8ClXiOxaE4LufHn4V4="; # TODO
      };
    }.${
      system
    } or throwSystem;

  extensions = [
    # DrBlury.protobuf-vsc # TODO: doesn't exist anymore
    "jacobwgillespie.minimal-icons"
    "franzgollhammer.jb-fleet-dark"

    "vadimcn.vscode-lldb"
    "wgsl-analyzer.wgsl-analyzer"
    "postman.postman-for-vscode"
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
  home.packages = [
    (pkgs.writeShellScriptBin "code" ''
      exec ${lib.getExe' config.programs.vscode.package "code-insiders"}
    '')
  ];

  programs = {
    vscode = {
      enable = true;
      package =
        (pkgs.vscode.override {
          isInsiders = true;
        }).overrideAttrs (oldAttrs: {
          version = "1.110.0";
          src = pkgs.fetchurl {
            name = "VSCode-insiders-darwin-arm64.zip";
            url = "https://update.code.visualstudio.com/latest/${source.os}/insider"; # TODO: version and linux
            sha256 = source.sha256;
          };
          # src = fetchTarball {
          #   # src = builtins.fetchurl {
          #   url = "https://code.visualstudio.com/sha/download?build=insider&os=${os}";
          #   sha256 = sha256;
          #   # url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin";
          #   # sha256 = lib.fakeSha256; # TODO
          # };
        });

      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        enableMcpIntegration = true;
        extensions = pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version extensions;
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
            "editor.fontFamily" = customArgs.font.name;
            "editor.fontSize" = customArgs.font.size;
            "editor.minimap.enabled" = false;
            "editor.formatOnSave" = true;
            "editor.renderWhitespace" = "trailing";
            "editor.lineNumbers" = "relative";
            "editor.wordSeparators" = "/\\()\"'=,.;<>~!@#$%^&*|+=[]{}`?-";
            "editor.inlineSuggest.suppressSuggestions" = true;
            "editor.inlayHints.enabled" = "offUnlessPressed";

            "terminal.integrated.fontSize" = customArgs.font.size;

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
          (withExtension "postman.postman-for-vscode" {
            # TODO
            # "chat.instructionsFilesLocations" = {
            #   "${extensions.postman.postman-for-vscode}/agent-instruction-files/vscode" = true;
            # };
          })
        ];
      };
    };
  };
}
