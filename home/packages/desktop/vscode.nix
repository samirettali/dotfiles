{ inputs
, pkgs
, lib
, ...
}:
let
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  fontSize = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin 13)
    (lib.mkIf pkgs.stdenv.isLinux 12)
  ];
in
{
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        eamodio.gitlens
        marketplace.amos402.scope-bar
        mkhl.direnv

        github.copilot
        github.copilot-chat

        jnoortheen.nix-ide
        golang.go
        rust-lang.rust-analyzer

        marketplace.juanblanco.solidity
      ] ++ [
        (lib.mkIf pkgs.stdenv.isDarwin (marketplace.ms-dotnettools.csdevkit.overrideAttrs (super: a: { sourceRoot = "."; })))
      ];
      keybindings = [ ];
      userSettings = {
        "editor.fontFamily" = "\"JetBrainsMono Nerd Font\"";
        "editor.fontSize" = fontSize;
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.renderWhitespace" = "trailing";
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

        # Go
        "go.formatTool" = "gofumpt";
        "go.delveConfig" = {
          "showGlobalVariables" = true;
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
