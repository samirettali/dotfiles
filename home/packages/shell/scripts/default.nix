{
  config,
  pkgs,
  lib,
  nurPkgs,
  ...
}: let
  copy = pkgs.callPackage ./copy.nix {};
  scriptsDir = ../../../dotfiles/scripts;
in {
  home.packages =
    [
      copy
      # (pkgs.callPackage ./speak.nix {
      #   rbw =
      #     if config.programs.rbw.enable
      #     then config.programs.rbw.package
      #     else null;
      # })
      (pkgs.callPackage ./lyrics.nix {
        inherit (nurPkgs) spotctl;
        rbw =
          if config.programs.rbw.enable
          then config.programs.rbw.package
          else null;
      })
      (pkgs.callPackage ./dev-sync.nix {})
      (pkgs.callPackage ./ccexport.nix {})
      (pkgs.callPackage ./pi-models.nix {})
      (pkgs.callPackage ./ai-usage.nix {
        inherit (nurPkgs) codex grok-cli;
        antigravity-cli = config.programs.antigravity-cli.package;
      })
      (pkgs.writeShellScriptBin "tad" (builtins.readFile "${scriptsDir}/tad.sh"))
      (pkgs.writeShellScriptBin "chezmoi-render" (builtins.readFile "${scriptsDir}/chezmoi-render.sh"))
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      (pkgs.writeShellScriptBin "passbemenu" (builtins.readFile "${scriptsDir}/passbemenu.sh"))
      (pkgs.writeShellScriptBin "screenshot" (builtins.readFile "${scriptsDir}/screenshot.sh"))
    ];
}
