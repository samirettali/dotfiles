# Set up a new app

1. Copy `assets/Makefile` to the repo root and `assets/make-dmg.sh` to
   `Packaging/`, then adapt: `APP_NAME`, and delete the icon line and the
   entitlements variable/flag if the app has neither.
2. Write `Packaging/Info.plist` by hand: `CFBundleIdentifier`,
   `CFBundleExecutable` and `CFBundleName` (the target name),
   `CFBundleShortVersionString` — the Makefile reads it to name the DMG —
   `LSMinimumSystemVersion`, `LSUIElement` for a menu bar app,
   `NSHighResolutionCapable`, `NSPrincipalClass`, and any `NS*UsageDescription`
   the app triggers.
3. Entitlements **only for what the hardened runtime actually blocks**:
   microphone, camera, Apple events, JIT. Plain outgoing network needs nothing.
   No App Sandbox — a CGEvent tap or Accessibility-driven input cannot work
   inside one.
4. CI is a compile check: `swift build -c release` then `make bundle`, which
   catches breakage in the Info.plist and the bundle layout. Nothing more.
5. The cask: write `Casks/<app>.rb` and a row in the tap README by hand. A
   `release: published` workflow in the app repo bumps `version` and `sha256`
   afterwards.

## Why it is built this way

Keep these when adapting the Makefile or the DMG script.

- **Dev builds are signed with the distribution identity too.** TCC grants and
  Keychain ACLs hang off the designated requirement; signing dev builds with a
  different identity makes macOS treat them as a different app and re-prompt for
  Microphone and Accessibility on every switch.
- **The certificate must carry a real Team ID.** Keychain item ACLs use
  `teamid:`-based partition lists. With a self-signed certificate the identity
  degrades to the per-binary cdhash and every rebuild re-prompts for the
  Keychain password, even after "Always Allow". Certificates renew yearly, but
  Team ID and leaf CN stay put, so grants survive renewal.
- **Hardened runtime on every build**, not just release, so dev builds hit the
  restrictions the shipped app hits.
- **Notarise twice, app and DMG.** The ticket stapled to a DMG only covers the
  app while it sits on the mounted image; dragged to /Applications the app needs
  its own ticket to launch offline.
- **Releases are built locally, never in CI.** CI would mean the Developer ID
  private key and the notarisation credentials in repository secrets, and the
  DMG step scripts Finder, which hosted runners can't do reliably.
- **The DMG layout is written by Finder** into a `.DS_Store` *inside* the image,
  so everyone opening it sees the same window rather than their own defaults.
  HFS+ rather than the APFS default — the safer filesystem for this, and it
  compresses better at `zlib-level=9`. The volume is mounted browsable because
  Finder has to see it to script it.
- **No background art in the DMG.** A background image is static, but Finder's
  icon labels turn white in dark mode, so a light background with a drawn arrow
  becomes unreadable. Position alone conveys the drag.
- **The cask declares `depends_on arch: :arm64`.** The DMG carries an arm64-only
  binary while `LSMinimumSystemVersion` still allows macOS versions that ran on
  Intel; without it an Intel user installs an app that cannot launch.
