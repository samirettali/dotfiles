{ inputs
, pkgs
, ...
}:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in
{
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = true; # TODO can it be handled with nix?
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        eamodio.gitlens
        marketplace.amos402.scope-bar

        github.copilot
        github.copilot-chat
        ms-vsliveshare.vsliveshare
        marketplace.sourcegraph.cody-ai

        bbenoist.nix
        golang.go
        rust-lang.rust-analyzer
        # ms-dotnettools.csharp
        (marketplace.ms-dotnettools.csdevkit.overrideAttrs (super: a: { sourceRoot = "."; })) # TODO fix this
      ];
      keybindings = [ ];
      userSettings = {
        "editor.fontFamily" = "\"JetBrainsMono Nerd Font\"";
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "trailing";
        "editor.wordSeparators" = "/\\()\"'=,.;<>~!@#$%^&*|+=[]{}`?-";
        "window.menuBarVisibility" = "toggle";

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

        # Go
        "go.formatTool" = "gofumpt";
        "go.delveConfig" = {
          "dlvLoadConfig" = {
            "followPointers" = true;
            "maxVariableRecurse" = 1;
            "maxStringLen" = 64;
            "maxArrayValues" = 64;
            "maxStructFields" = -1;
          };
          "apiVersion" = 2;
          "showGlobalVariables" = false;
          "debugAdapter" = "legacy";
          "substitutePath" = [ ];
          "maxStringLen" = 10000;
        };
        "go.lintTool" = "golangci-lint";
        "go.lintFlags" = [
          "--enable-all"
        ];
        "go.coverOnSingleTest" = true;
        "go.showWelcome" = true;

        "gitlens.showWelcomeOnInstall" = false;

        "vim.handleKeys" = {
          "<C-p>" = false;
        };
      };
    };
  };
}
