{
  pkgs,
  lib,
  passphraseFiles,
  ...
}: let
  cat = lib.getExe' pkgs.coreutils "cat";
  known = lib.concatStringsSep " " (lib.attrNames passphraseFiles);
  cases =
    lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: path: ''${name}) file=${path} ;;'') passphraseFiles);
in
  # Prints the OpenTofu state encryption configuration for TF_ENCRYPTION, with
  # the passphrase read from sops at call time so it never lands in a file.
  #
  #   export TF_ENCRYPTION="$(tofu-encryption infra)"
  #
  # One passphrase per state bucket, not per workspace: they share a bucket, and
  # a bucket is the unit that could be handed to someone else.
  pkgs.writeShellScriptBin "tofu-encryption" ''
    set -euo pipefail

    enforced=true
    name=""

    for arg in "$@"; do
      case "$arg" in
        # For migrating an already-unencrypted state: OpenTofu has to be allowed
        # to read the plaintext once before it can rewrite it encrypted.
        --no-enforce) enforced=false ;;
        -*) echo "tofu-encryption: unknown option $arg" >&2; exit 2 ;;
        *) name="$arg" ;;
      esac
    done

    case "$name" in
    ${cases}
      "") echo "usage: tofu-encryption <${lib.concatStringsSep "|" (lib.attrNames passphraseFiles)}> [--no-enforce]" >&2; exit 2 ;;
      *) echo "tofu-encryption: no passphrase named '$name' (known: ${known})" >&2; exit 2 ;;
    esac

    if [ ! -r "$file" ]; then
      echo "tofu-encryption: $file is missing — run home-manager and check the sops age key" >&2
      exit 1
    fi

    passphrase=$(${cat} "$file")

    # pbkdf2 refuses anything shorter, with a message that is easy to misread as
    # a configuration error.
    if [ "''${#passphrase}" -lt 16 ]; then
      echo "tofu-encryption: the passphrase in $file is shorter than 16 characters" >&2
      exit 1
    fi

    case "$passphrase" in
      *'"'*|*'\'*)
        echo "tofu-encryption: the passphrase contains a quote or a backslash, which would break the HCL" >&2
        exit 1
        ;;
    esac

    cat <<EOF
    key_provider "pbkdf2" "passphrase" {
      passphrase = "$passphrase"
    }
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.passphrase
    }
    state {
      method   = method.aes_gcm.default
      enforced = $enforced
    }
    EOF
  ''
