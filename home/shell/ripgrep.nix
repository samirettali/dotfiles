{
  lib,
  pkgs,
  ...
}: let
  preprocessor = pkgs.writeShellScriptBin "rg-preprocessor" ''
    case "$1" in
    *.pdf)
      # The -s flag ensures that the file is non-empty.
      if [ -s "$1" ]; then
        exec ${lib.getExe' pkgs.poppler_utils "pdftotext"} - - # TODO: find a faster alternative
      else
        exec cat
      fi
      ;;
    *)
      exec cat
      ;;
    esac
  '';
in {
  programs.ripgrep = {
    enable = lib.mkDefault true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!node_modules/*"
      "--glob=!.git/*"
      "--hidden"
      "--smart-case"
    ];
  };

  home.shellAliases = {
    rgb = "${lib.getExe pkgs.ripgrep} --pre=${lib.getExe preprocessor}";
  };
}
