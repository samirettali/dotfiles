{
  pkgs,
  lib,
  entries,
  ...
}: let
  rbw = lib.getExe pkgs.rbw;
  known = lib.concatStringsSep " " (lib.attrNames entries);
  cases =
    lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: entry: ''${name}) vault_entry=${entry} ;;'') entries);
in
  # Prints the OpenTofu state encryption configuration for TF_ENCRYPTION, with
  # the passphrase read from the vault at call time so it never lands in a file.
  #
  #   export TF_ENCRYPTION="$(tofu-encryption infra)"
  #
  # The vault rather than sops: this passphrase protects state that carries live
  # credentials, and the dotfiles repo is public — encrypted, but the ciphertext
  # and the names stay in its history forever. Tofu is only ever run by hand, so
  # needing an unlocked agent costs nothing.
  #
  # One passphrase per state bucket, not per workspace: they share a bucket, and
  # a bucket is the unit that could be handed to someone else.
  pkgs.writeShellScriptBin "tofu-encryption" ''
    set -euo pipefail

    enforced=true
    migrate=false
    name=""

    for arg in "$@"; do
      case "$arg" in
        # For a state that is still plaintext. `enforced = false` is not enough:
        # it only lets OpenTofu write in the clear, while reading an unencrypted
        # payload needs the unencrypted method as an explicit fallback. Without
        # it, init fails with "encountered unencrypted payload without
        # unencrypted method configured". Drop the flag after the first apply.
        --migrate) migrate=true; enforced=false ;;
        -*) echo "tofu-encryption: unknown option $arg" >&2; exit 2 ;;
        *) name="$arg" ;;
      esac
    done

    case "$name" in
    ${cases}
      "") echo "usage: tofu-encryption <${lib.concatStringsSep "|" (lib.attrNames entries)}> [--no-enforce]" >&2; exit 2 ;;
      *) echo "tofu-encryption: no passphrase named '$name' (known: ${known})" >&2; exit 2 ;;
    esac

    if ! passphrase=$(${rbw} get "$vault_entry" 2>&1); then
      echo "tofu-encryption: cannot read '$vault_entry' from the vault:" >&2
      echo "$passphrase" >&2
      exit 1
    fi

    # pbkdf2 refuses anything shorter, with a message that is easy to misread as
    # a configuration error.
    if [ "''${#passphrase}" -lt 16 ]; then
      echo "tofu-encryption: the passphrase in '$vault_entry' is shorter than 16 characters" >&2
      exit 1
    fi

    case "$passphrase" in
      *'"'*|*'\'*)
        echo "tofu-encryption: the passphrase contains a quote or a backslash, which would break the HCL" >&2
        exit 1
        ;;
    esac

    fallback=""
    unencrypted=""
    if [ "$migrate" = true ]; then
      unencrypted='method "unencrypted" "migrate" {}'
      fallback='  fallback { method = method.unencrypted.migrate }'
    fi

    cat <<EOF
    $unencrypted
    key_provider "pbkdf2" "passphrase" {
      passphrase = "$passphrase"
    }
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.passphrase
    }
    state {
      method   = method.aes_gcm.default
      enforced = $enforced
    $fallback
    }
    EOF
  ''
