{pkgs, ...}:
pkgs.writeShellScriptBin "ccexport" ''
  exec ${pkgs.python3}/bin/python3 ${./ccexport.py} "$@"
''
