{
  config,
  customArgs,
  lib,
  pkgs,
  ...
}: let
  cursorSettings =
    (builtins.removeAttrs config.programs.vscode.profiles.default.userSettings ["workbench.colorTheme"])
    // {"cursor.composer.shouldChimeAfterChatFinishes" = true;};

  withExtension = ext: settings:
    lib.optionalAttrs (builtins.elem ext config.programs.vscode.profiles.default.extensions) settings;
in {
  home.file."Library/Application Support/Cursor/User/settings.json".text =
    builtins.toJSON cursorSettings;
  home.file."Library/Application Support/Cursor/User/keybindings.json".text =
    builtins.toJSON config.programs.vscode.profiles.default.keybindings;

  programs = {
    vscode = {
      enable = true;
      # package =
      # (pkgs.vscode.override {
      #   isInsiders = true;
      # }).overrideAttrs (old: rec {
      #   src = builtins.fetchurl {
      #     url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/8c0b3c16f47d628d0d767358d5a3fa1d95237f70/VSCode-darwin-arm64.zip"; # TODO: hardcoded darwin-arm64
      #     sha256 = "sha256-ksJaMW3fwSKszMdU7XRFW+nwlnqAfYaGZV5TzebS6Qs=";
      #   };
      #   postInstall = ''
      #     ${old.postInstall or ""}
      #     chmod +x $out/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code
      #     ln -s $out/bin/code-insiders $out/bin/code
      #     # xattr -d com.apple.quarantine $out/Applications/Visual\ Studio\ Code\ -\ Insiders.app || true
      #   '';
      # });
      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = with pkgs.vscode-marketplace; [
          eamodio.gitlens
          vscodevim.vim
          franzgollhammer.jb-fleet-dark

          zxh404.vscode-proto3
          rust-lang.rust-analyzer
          wgsl-analyzer.wgsl-analyzer

          github.vscode-github-actions
          github.vscode-pull-request-github

          google.geminicodeassist
          sourcegraph.amp
          rooveterinaryinc.roo-cline
          supermaven.supermaven
          jacobwgillespie.minimal-icons
          # continue.continue
          # vadimcn.vscode-lldb # TODO: build is broken
          # postman.postman-for-vscode
          # saoudrizwan.claude-dev
          # github.copilot
          # github.copilot-chat
          # augment.vscode-augment
          # kilocode.kilo-code
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
          {
            "key" = "ctrl+g";
            "command" = "workbench.action.findInFiles";
          }
          {
            "key" = "ctrl+f";
            "command" = "workbench.action.quickOpen";
          }
        ];
        userMcp = {
          "servers" = {
            "context7" = {
              "type" = "http";
              "url" = "https://mcp.context7.com/mcp";
            };
            "playwright" = {
              "command" = "npx";
              "args" = [
                "@playwright/mcp@latest"
              ];
            };
          };
        };
        userSettings = lib.mkMerge [
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

            "terminal.integrated.fontSize" = 13;

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
            "chat.instructionsFilesLocations" = {
              ".github/instructions" = true;
            };
          }
          (withExtension pkgs.vscode-marketplace.jacobwgillespie.minimal-icons {
            "workbench.iconTheme" = "minimal-icons-without-explorer-arrows";
          })
          (withExtension pkgs.vscode-marketplace.franzgollhammer.jb-fleet-dark {
            "workbench.colorTheme" = "Fleet Sphere";
          })
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
          (withExtension pkgs.vscode-marketplace.github.copilot {
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
          (withExtension pkgs.vscode-marketplace.eamodio.gitlens {
            "gitlens.advanced.blame.customArguments" = [
              "-w"
              "-CCC"
            ];
          })
          (withExtension pkgs.vscode-marketplace.augment.vscode-augment {
            "augment.disableFocusOnAugmentPanel" = true;
          })
          # (withExtension pkgs.vscode-marketplace.postman.postman-for-vscode {
          #   # TODO
          #   "chat.instructionsFilesLocations" = {
          #     "${pkgs.vscode-marketplace.postman.postman-for-vscode}/agent-instruction-files/vscode" = true;
          #   };
          # })
        ];
      };
    };
  };
}
