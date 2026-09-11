---
name: macos-app-release
disable-model-invocation: true
description: Sign, notarise and ship Samir's macOS apps — Developer ID signing, hardened runtime, notarised DMG, Homebrew cask. Use when setting up packaging for a new macOS app, cutting a release of one, or debugging codesign, notarytool, stapler or Gatekeeper failures.
---

# Shipping a macOS app

Applies to the SwiftPM menu bar apps under `~/dev` — currently `sottovoce` and
`pulse`. Each repo's `AGENTS.md` holds what is specific to it (bundle id,
entitlements, cask name); everything below is shared.

Read the reference for the operation, relative to this skill:

| Work | Read |
| --- | --- |
| Packaging a new app, or changing the Makefile or DMG script | [Setup](references/setup.md) |
| Shipping a version | [Release](references/release.md) |
| codesign, notarytool, stapler, DMG or permission failures | [Troubleshooting](references/troubleshooting.md) |

## Fixed facts

| | |
| --- | --- |
| Certificate | `Developer ID Application: Samir Ettali (22K9H4B864)` |
| Team ID | `22K9H4B864` |
| Apple ID | `samir@ettali.com` |
| notarytool profile | `notary` — one for all apps, the credentials belong to the account |
| Bundle id | `com.samirettali.<app>` — reverse DNS of a domain actually owned |
| Tap | `samirettali/homebrew-tap`, casks in `Casks/<app>.rb` |

## Keeping the copies in step

`make-dmg.sh` is **copied** into each repo, not linked: the repos are public and
must build without these dotfiles. `assets/make-dmg.sh` here is the canonical
copy — fix it here first, then propagate to every repo that has one. The same
goes for the parts of the Makefile that are not app-specific.
