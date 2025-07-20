{
  copyCmd,
  lib,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "nh" ''
  set -euo pipefail

  if [ -z "''${1:-}" ]; then
    echo "Error: URL argument is required." >&2
    exit 1
  fi

  hash=${lib.getExe' pkgs.nix "nix-prefetch-url"} --type sha256 "''${1}" 2>/dev/null
  sri_hash=$(${lib.getExe pkgs.nix} hash to-sri --type sha256 ''${hash})

  echo "''${sri_hash}"
  echo "''${sri_hash}" | ${lib.getExe' pkgs.uutils-coreutils-noprefix "tr"} -d '\n' | ${copyCmd}
  echo "Copied to clipboard!" >&2
''
