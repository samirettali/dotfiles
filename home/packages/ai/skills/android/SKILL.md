---
name: android
description: Diagnose Android apps, drive their UI, and resolve APK installation problems on physical devices or emulators through adb.
---

# Android

Everything here needs `adb` and a device with USB debugging authorised. In these
dotfiles `adb` comes from `android-tools`, behind the `android` host feature.

## Choose the relevant reference

Resolve these paths relative to this skill and load only what the task needs:

| Task | Read |
| --- | --- |
| Diagnose a failure, capture logs, reproduce, or instrument | [Diagnosis](references/diagnosis.md) |
| Inspect or drive the UI with Maestro or screenshot coordinates | [UI interaction](references/ui.md) |
| Install an APK or resolve signature/profile conflicts | [Installation](references/installation.md) |

## Device and safety boundaries

Identify the target with `adb devices -l`. With several devices attached, use
`-s "$SERIAL"` for adb commands and select the same device in other tools.
Confirm the package before changing app state.

- **Stop before anything irreversible.** Sending, signing, paying, confirming,
  deleting: drive up to the review screen and hand back. Only go through if that
  was explicitly the request.
- **Uninstalling deletes app data.** Explain the affected package/profile and ask
  before uninstalling; never remove a neighbouring package just because its name
  shares a prefix.
- **Logs are sensitive.** Device logs carry bearer tokens, JWTs, cookies, request
  bodies and sometimes keys. Do not paste them into a report, commit or issue.
  If some were exposed while capturing, say so and recommend rotating them. Ask
  before enabling verbose logging likely to contain them.
- Announce a log wipe before running it: the buffer may hold existing evidence.
