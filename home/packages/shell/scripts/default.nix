{
  config,
  pkgs,
  nurPkgs,
  ...
}: let
  copy = pkgs.callPackage ./copy.nix {};
  scriptsDir = ../../../dotfiles/scripts;
in {
  home.packages = [
    copy
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
      inherit (nurPkgs) codex;
    })
    # (pkgs.writeShellScriptBin "tad" (builtins.readFile "${scriptsDir}/tad.sh"))
    (pkgs.writeShellScriptBin "chezmoi-render" (builtins.readFile "${scriptsDir}/chezmoi-render.sh"))
  ];
}
