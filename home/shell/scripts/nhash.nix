{
  copy,
  lib,
  pkgs,
  ...
}: let
  nix-prefetch-url = lib.getExe' pkgs.nix "nix-prefetch-url";
  nixHash = lib.getExe' pkgs.nix "hash";
  tr = lib.getExe' pkgs.uutils-coreutils-noprefix "tr";
in
  pkgs.writeShellScriptBin "nhash" ''
    set -euo pipefail

    if [ -z "''${1:-}" ]; then
      echo "Error: URL argument is required." >&2
      exit 1
    fi

    hash=$(${nix-prefetch-url} --type sha256 "''${1}" 2>/dev/null)
    sri_hash=$(${nixHash} convert --hash-algo sha256 --to sri ''${hash})

    echo "''${sri_hash}"
    echo "''${sri_hash}" | ${tr} -d '\n' | ${lib.getExe copy}
    echo "Copied to clipboard!" >&2
  ''
