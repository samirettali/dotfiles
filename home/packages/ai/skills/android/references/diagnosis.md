# Diagnosis

## Diagnose the installed failure first

When diagnosing a failure in the installed app, prefer its logs and state before
rebuilding: a build costs minutes and changes the reproduction. Build when the task
requires changed code or instrumentation, or when the installed diagnostics are
insufficient; reading those logs is not a prerequisite for every build.

## Identify the installed app

```sh
adb -s "$SERIAL" shell dumpsys package "$PKG" | rg 'versionCode|versionName|debuggable'
adb -s "$SERIAL" shell pidof "$PKG"
```

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
what the app does can be lined up. The **herdr** skill covers running it beside you.

Record the app version, package, pid, device model and OS before reproducing. Half of the
confusing sessions are a build that is not the one everyone assumes.

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

## Instrumentation

Reach for existing logs and state getters before adding anything. When a marker is
genuinely needed, log booleans, counts, names, status codes and stack traces — not tokens
or response bodies — and do not change control flow while diagnosing. Keep those edits
uncommitted, list them at handoff, and remove only what the session added: a dirty worktree
usually holds someone else's work too.
