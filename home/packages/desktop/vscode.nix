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
        eamodio.gitlens
        golang.go
        vscodevim.vim
        github.copilot
        github.copilot-chat
        bbenoist.nix

        ms-dotnettools.csharp
        # sourcegraph.cody-ai
        # ms-vsliveshare.vsliveshare # not available in inxpkgs for darwin
        # sourcegraph.cody-ai
        # amos402.scope-bar
      ] ++ [
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
