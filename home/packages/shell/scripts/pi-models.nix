{
  lib,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "pi-models" ''
  exec ${lib.getExe pkgs.nodejs} ${./pi-models}/server.mjs "$@"
''
