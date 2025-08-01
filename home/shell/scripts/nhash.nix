{
  copy,
  lib,
  pkgs,
  ...
}: let
  nixPrefetchUrlExe = lib.getExe' pkgs.nix "nix-prefetch-url";
  nixExe = lib.getExe pkgs.nix;
  trExe = lib.getExe' pkgs.uutils-coreutils-noprefix "tr";
in
  pkgs.writeShellScriptBin "nhash" ''
    set -euo pipefail

    if [ -z "''${1:-}" ]; then
      echo "Error: URL argument is required." >&2
      exit 1
    fi

    hash=$(${nixPrefetchUrlExe} --type sha256 "''${1}" 2>/dev/null)
    sri_hash=$(${nixExe} hash convert --hash-algo sha256 --to sri ''${hash})

    echo "''${sri_hash}"
    echo "''${sri_hash}" | ${trExe} -d '\n' | ${lib.getExe copy}
    echo "Copied to clipboard!" >&2
  ''
