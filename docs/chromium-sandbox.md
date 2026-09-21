# Chromium sandbox on andromeda

Read before changing `home/packages/dev/headless-browser.nix`. Nix owns the user
profile; a host policy or setuid helper belongs in `servers` and requires a
separate approved Ansible change. The current `--no-sandbox` remains a security
exception, not a statement that Chromium cannot be sandboxed on Ubuntu.

## Reproduced on the host

- Ubuntu 24.04, Linux 6.8.0-138-generic, aarch64; the browser runs as user `samir`.
- `kernel.unprivileged_userns_clone=1`, `user.max_user_namespaces=62020`.
- `kernel.apparmor_restrict_unprivileged_userns=1`.
- `unshare --user --map-root-user true` fails writing `uid_map` with
  `Operation not permitted`.
- The distro's `/etc/apparmor.d/chrome` grants `userns` to
  `/opt/google/chrome/chrome`, not to the Nix Chromium executable.
- nixpkgs points `CHROME_DEVEL_SANDBOX` at `/run/wrappers/bin/__chromium-suid-sandbox`
  when present, otherwise at its store helper. The former is absent; the store
  helper is root-owned but mode 0555, not setuid.
- Starting the underlying ungoogled Chromium 153.0.8010.47 wrapper directly,
  without our `--no-sandbox`, with `--disable-setuid-sandbox`, a temporary profile,
  no background networking and `--dump-dom about:blank`, aborts with
  **No usable sandbox** (exit 134). This was a bounded, non-root smoke test, not a
  browser session with real data. The temporary profile was removed.

The namespace path is therefore blocked in the current environment. Removing
our flag alone is not a working fix. These observations do not establish that a
specific AppArmor profile is sufficient: that needs a privileged, approved test.

## Candidate change, not applied

Prefer investigating a narrowly scoped AppArmor `userns` allowance for the
actual Nix Chromium executable over disabling the restriction globally. The
attachment must match the real `libexec/chromium/chromium` binary, not just the
profile's shell wrapper, and survive approved Nix version changes without
covering arbitrary store executables. Review the AppArmor denial logs and the
installed policy before choosing that attachment.

If the user authorizes the work, implement and test the policy in `servers`:

1. Capture baseline failures and the applicable AppArmor denial.
2. Load the narrowly scoped profile through Ansible, with an explicit rollback.
3. Re-run the isolated browser without `--no-sandbox`; inspect `chrome://sandbox`
   and renderer processes to verify the namespace and seccomp sandboxes, rather
   than treating successful startup as proof.
4. Test navigation, screenshots and CDP interactions as the non-root user.
5. Only then remove the unconditional bypass in dotfiles, coordinate activation,
   and verify the ordinary browser skill path.

A root-managed setuid helper is an alternative if the namespace route cannot be
made to work, but is a separate security and lifecycle decision. Do not chmod a
Nix-store file or disable AppArmor globally as a shortcut.
