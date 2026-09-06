# Installing without losing data

```sh
adb -s "$SERIAL" install -r "$APK"        # keep data
adb -s "$SERIAL" install -r -d "$APK"     # allow version downgrade
```

`INSTALL_FAILED_UPDATE_INCOMPATIBLE` means the signatures differ — a locally signed build
against a store-signed one, or two different local keys. The only fix is uninstalling,
**which deletes that app's data**. Stop and ask; the user may have state in there worth
more than the debug session.

## The signature conflict that survives an uninstall

If installation still reports a signature mismatch after the app is gone from the launcher,
it is not gone. Private Space, work profiles and secondary users each hold their own copy,
and the launcher only shows one profile.

```sh
adb -s "$SERIAL" logcat -d -v time PackageInstaller:V PackageManager:V PackageManagerService:V '*:S' | tail -250
adb -s "$SERIAL" shell pm list users
adb -s "$SERIAL" shell pm list packages -u | rg "$PKG"
adb -s "$SERIAL" shell dumpsys package "$PKG" | rg -n -A 8 'User [0-9]+:'
```

Two signals confirm it: `Existing package ... signatures do not match newer version` in the
Package Manager log, and a profile reporting `installed=true` while the owner profile says
`installed=false`.

Remove it from that profile only, after explaining that its data goes with it:

```sh
adb -s "$SERIAL" shell pm uninstall --user "$USER_ID" "$PKG"
```

Never uninstall a neighbouring package that merely shares a prefix — a staging and a
production build often differ by a suffix, and removing the wrong one destroys real data.
