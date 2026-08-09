---
name: android
description: Drive and diagnose an Android app on a physical device or emulator over adb — scope logcat to one process, reproduce a bug from a clean start, install builds without losing data, resolve signature conflicts hiding in another user profile, and navigate the UI by screenshot and input events when no inspector can see into it. Triggers on adb, logcat, Android device, emulator, APK, screencap, "install failed", INSTALL_FAILED_UPDATE_INCOMPATIBLE, uiautomator, driving an app on a phone, Flutter or Compose UI on device.
---

# Debugging an Android app over adb

Everything here needs `adb` and a device with USB debugging authorised. `adb` alone
captures logs, installs builds, takes screenshots and injects input, which is enough to
reproduce and diagnose most problems.

In these dotfiles `adb` comes from `android-tools`, behind the `android` feature — if the
command is missing, that feature is off for this host rather than the package being absent.

## Attach before building

The instinct to rebuild first is usually wrong. A build costs minutes and changes the thing
being debugged; the installed app is the one showing the bug. Rebuild only once the
installed app's logs have been read and shown to be insufficient — typically because it is
a release build with diagnostics stripped.

## Identify what you are talking to

```sh
adb devices -l                                   # serial, model, state
adb -s "$SERIAL" shell wm size                   # real resolution, for tap coordinates
adb -s "$SERIAL" shell dumpsys package "$PKG" | rg 'versionCode|versionName|debuggable'
adb -s "$SERIAL" shell pidof "$PKG"
```

With several devices attached, `-s "$SERIAL"` is not optional — without it `adb` picks one
and the whole session may be aimed at the wrong phone.

`debuggable=true` is what decides whether the app will emit anything useful. A store build
will not.

## A clean reproduction

Announce the log wipe before running it: the buffer may hold evidence of something the user
already reproduced.

```sh
adb -s "$SERIAL" logcat -c
adb -s "$SERIAL" shell am force-stop "$PKG"
adb -s "$SERIAL" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1
adb -s "$SERIAL" logcat --pid="$(adb -s "$SERIAL" shell pidof "$PKG")" -v threadtime
```

`monkey` with the LAUNCHER category starts the app the way tapping its icon does, without
needing to know the activity name. `--pid` is what makes logcat readable: the unfiltered
buffer is mostly other apps.

Keep that log running in another pane while driving the UI, so what appears on screen and
what the app does can be lined up. The `herdr` skill covers running it beside you.

Record the app version, package, pid, device model and OS before reproducing. Half of the
confusing sessions are a build that is not the one everyone assumes.

## Driving the UI: try by name first

There are two ways to act on the UI, and the order matters. Addressing an element **by its
text or id** survives a layout change, a different device and a different screen density.
Addressing it **by coordinates** does not — it breaks silently, tapping whatever moved into
that spot.

So start with `maestro`, and fall back to coordinates only when the element cannot be
reached by name.

First find out what the app exposes:

```sh
maestro hierarchy | head -60
```

This prints the accessibility tree — the same one `uiautomator dump` reads, and the only
thing `maestro` can see. What you get back decides the approach:

- **Nodes with `text` and `resource-id`** — address elements by name. Visible text is
  almost always there, because frameworks expose text labels for free.
- **One node covering the whole screen, or nothing useful** — the UI is drawn onto a single
  surface (Flutter without semantics, games, canvas) and nothing is addressable. Go to
  coordinates.

Icon-only buttons are the common gap even in otherwise well-built apps: they need a
`contentDescription` or a `Semantics(label:)` that nobody wrote. Text works, the icon next
to it does not.

A flow is a YAML file, run with `maestro test flow.yaml`:

```yaml
appId: com.example.app
---
- launchApp
- tapOn: "Continue"
- inputText: "hello world"
- assertVisible: "Welcome"
```

`inputText` handles spaces and punctuation, which `adb shell input text` does not — reason
enough to prefer it for anything typed.

`maestro` also ships an MCP server (`maestro mcp`) that exposes these actions as tools; if
it is declared in `mcp.nix` the actions are callable directly, without writing a flow file.

### Falling back to coordinates

When nothing is addressable, the loop is: screenshot, look at it, act, screenshot again to
confirm the act landed. Never fire a sequence of taps blind.

```sh
adb -s "$SERIAL" exec-out screencap -p > /tmp/screen.png
adb -s "$SERIAL" shell input tap X Y
adb -s "$SERIAL" shell input swipe X1 Y1 X2 Y2 300
adb -s "$SERIAL" shell input text "hello%sworld"
adb -s "$SERIAL" shell input keyevent 4     # back
adb -s "$SERIAL" shell input keyevent 66    # enter
```

`exec-out` streams the PNG straight to the host — no temp file to write and delete on the
device.

Things that cost time if you learn them the hard way:

- **Coordinates are physical pixels of the full-resolution screenshot.** If the image is
  viewed downscaled, multiply before tapping. `wm size` gives the truth.
- **`input text` types into whatever has focus** — tap the field first. It does not take
  spaces (use `%s`) and mangles most special characters. For anything with punctuation,
  prefer `maestro`'s `inputText`, which handles both.
- **A debug build can take twenty seconds to its first frame.** Screenshot again before
  concluding it hung on a black screen.
- **Stop before anything irreversible.** Sending, signing, paying, confirming, deleting:
  drive up to the review screen and hand back. Only go through if that was explicitly the
  request.

## Installing without losing data

```sh
adb -s "$SERIAL" install -r "$APK"        # keep data
adb -s "$SERIAL" install -r -d "$APK"     # allow version downgrade
```

`INSTALL_FAILED_UPDATE_INCOMPATIBLE` means the signatures differ — a locally signed build
against a store-signed one, or two different local keys. The only fix is uninstalling,
**which deletes that app's data**. Stop and ask; the user may have state in there worth
more than the debug session.

### The signature conflict that survives an uninstall

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

## Reading logs

Capture raw and filter afterwards, so nothing is lost to a pattern chosen too early:

```sh
adb -s "$SERIAL" logcat --pid="$PID" -v threadtime > /tmp/app.log
rg -i 'exception|error|fatal|ANR|timeout|refused|[45][0-9][0-9]' /tmp/app.log
```

Then build a timeline across the boundaries the app crosses — process start, framework
ready, auth, first network call, the failing operation — and find the *first* thing that
went wrong. The visible error is usually several steps downstream of the cause.

Lead with the evidence, and say which parts are confirmed and which are hypothesis.

## Secrets

Device logs carry bearer tokens, JWTs, cookies, request bodies and sometimes keys. Do not
paste them into a report, a commit or an issue. If some were exposed while capturing, say
so and recommend rotating them. Ask before enabling verbose logging that is likely to
contain them.

## Instrumentation

Reach for existing logs and state getters before adding anything. When a marker is
genuinely needed, log booleans, counts, names, status codes and stack traces — not tokens
or response bodies — and do not change control flow while diagnosing. Keep those edits
uncommitted, list them at handoff, and remove only what the session added: a dirty worktree
usually holds someone else's work too.
