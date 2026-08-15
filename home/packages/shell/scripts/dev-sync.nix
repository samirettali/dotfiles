{
  pkgs,
  lib,
  git,
  ...
}:
pkgs.writeShellScriptBin "dev-sync" ''
  export PATH=${lib.makeBinPath [git]}:"$PATH"

  ${builtins.readFile ../../../dotfiles/scripts/dev-sync.sh}
''
