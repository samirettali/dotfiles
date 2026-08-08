---
name: macos-app-release
description: Sign, notarise and ship Samir's macOS apps — Developer ID signing, hardened runtime, notarised DMG, Homebrew cask. Use when setting up packaging for a new macOS app, cutting a release of one, or debugging codesign, notarytool, stapler or Gatekeeper failures.
---

# Shipping a macOS app

Applies to the SwiftPM menu bar apps under `~/dev` — currently `sottovoce` and
`pulse`. Each repo's `AGENTS.md` holds what is specific to it (bundle id,
entitlements, cask name); everything below is shared.

## Fixed facts

| | |
| --- | --- |
| Certificate | `Developer ID Application: Samir Ettali (22K9H4B864)` |
| Team ID | `22K9H4B864` |
| Apple ID | `samir@ettali.com` |
| notarytool profile | `notary` — one for all apps, the credentials belong to the account |
| Bundle id | `com.samirettali.<app>` — reverse DNS of a domain actually owned |
| Tap | `samirettali/homebrew-tap`, casks in `Casks/<app>.rb` |

A new machine needs one `xcrun notarytool store-credentials notary --apple-id
samir@ettali.com --team-id 22K9H4B864 --password <app-specific-password>`, plus
the Developer ID certificate and key imported into the login keychain.

## Set up a new app

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

## Cut a release

1. Bump `CFBundleShortVersionString` in `Packaging/Info.plist` (and
   `CFBundleVersion`), commit.
2. `make release` — signs, notarises the app, staples it, builds and signs the
   DMG, notarises and staples that too, then asserts with `spctl`.
3. `gh release create v<version> dist/<App>-<version>.dmg --generate-notes`.
4. The cask: a `release: published` workflow in the app repo bumps `version` and
   `sha256` in the tap. A new app needs its `Casks/<app>.rb` and a row in the
   tap README written by hand.

Verify anything suspicious with `xcrun stapler validate <path>` and
`spctl --assess --type exec -vv <app>`, which should say
`source=Notarized Developer ID`.

## Why it is built this way

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

## When it breaks

| Symptom | Cause |
| --- | --- |
| codesign: "unable to build chain to self-signed root", `errSecInternalComponent` | Only the expired WWDR **G1** intermediate is installed. Add https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer to the login keychain; it chains to the Apple Root CA already in the system roots. |
| `make dmg` lays out the wrong disk | A stale `/Volumes/<App>` pushed the new mount to `<App> 1`. `make-dmg.sh` reads the mount point back from `hdiutil` — unmount the stale one. |
| `make dmg` hangs or the AppleScript is refused | Automation consent: macOS prompts once for whatever process runs `make dmg`, terminal included. |
| Permissions re-prompt on every build | Signing fell back to Apple Development or ad-hoc. `make bundle` warns when it does; check `security find-identity -p codesigning`. |
| Two menu bar items, or a hotkey firing twice | An old instance is still running. `make run` and `make dev` `pkill` first for this reason. |
| Notarisation rejected | `xcrun notarytool log <submission-id> --keychain-profile notary` gives the actual reason — usually a missing hardened runtime or an unsigned nested binary. |

## Keeping the copies in step

`make-dmg.sh` is **copied** into each repo, not linked: the repos are public and
must build without these dotfiles. `assets/make-dmg.sh` here is the canonical
copy — fix it here first, then propagate to every repo that has one. The same
goes for the parts of the Makefile that are not app-specific.
