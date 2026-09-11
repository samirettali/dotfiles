# Cut a release

1. Bump `CFBundleShortVersionString` in `Packaging/Info.plist` (and
   `CFBundleVersion`), commit.
2. `make release` — signs, notarises the app, staples it, builds and signs the
   DMG, notarises and staples that too, then asserts with `spctl`.
3. `gh release create v<version> dist/<App>-<version>.dmg --generate-notes`.
4. The `release: published` workflow in the app repo bumps `version` and
   `sha256` in the tap; check it ran.

Verify anything suspicious with `xcrun stapler validate <path>` and
`spctl --assess --type exec -vv <app>`, which should say
`source=Notarized Developer ID`.
