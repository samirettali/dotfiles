{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
  ];

  programs =
    let
      marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
    in
    {
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

          ms-dotnettools.csharp
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

          "diffEditor.ignoreTrimWhitespace" = false;

          "files.exclude" = {
            "**/.classpath" = true;
            "**/.project" = true;
            "**/.settings" = true;
            "**/.factorypath" = true;
          };

          "telemetry.telemetryLevel" = "off";

          "workbench.tree.indent" = 2;
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
        };
      };
    };
}
