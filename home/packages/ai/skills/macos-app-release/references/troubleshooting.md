# When it breaks

| Symptom | Cause |
| --- | --- |
| codesign: "unable to build chain to self-signed root", `errSecInternalComponent` | Only the expired WWDR **G1** intermediate is installed. Add https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer to the login keychain; it chains to the Apple Root CA already in the system roots. |
| `make dmg` lays out the wrong disk | A stale `/Volumes/<App>` pushed the new mount to `<App> 1`. `make-dmg.sh` reads the mount point back from `hdiutil` — unmount the stale one. |
| `make dmg` hangs or the AppleScript is refused | Automation consent: macOS prompts once for whatever process runs `make dmg`, terminal included. |
| Permissions re-prompt on every build | Signing fell back to Apple Development or ad-hoc. `make bundle` warns when it does; check `security find-identity -p codesigning`. |
| Two menu bar items, or a hotkey firing twice | An old instance is still running. `make run` and `make dev` `pkill` first for this reason. |
| Notarisation rejected | `xcrun notarytool log <submission-id> --keychain-profile notary` gives the actual reason — usually a missing hardened runtime or an unsigned nested binary. |

A new machine needs `xcrun notarytool store-credentials notary --apple-id
samir@ettali.com --team-id 22K9H4B864 --password <app-specific-password>`, plus
the Developer ID certificate and key imported into the login keychain.
