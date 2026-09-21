# Driving the UI

## Try by name first

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

`maestro` installs its own driver on the device, and it conflicts with UIAutomator2: tools
built on the latter (mobile-use, the `uiautomator2` Python package) uninstall Maestro's
package when they connect. Do not point both at the same device.

## The interaction loop

Whichever way an element is addressed, the loop is observe, act, observe. Some rules that
keep it honest:

- **Combine the hierarchy and the screenshot.** The hierarchy finds elements by name but
  sees no colour, badge, image or overlay; the screenshot sees all of that but gives no
  reliable coordinates. After a tap that should change the screen, take a screenshot to
  confirm it did, even when the tap was by name.
- **One unpredictable action per turn.** Back, launching or stopping an app, a deep link,
  a tap that navigates: each of these changes the screen in ways that cannot be planned
  around. Run it alone, then look at the new screen before deciding the next step.
- **Never retry a failed action unchanged.** Understand why first. A tap out of bounds means
  the bounds are stale; an element not found means the screen changed under you. Both
  call for a fresh hierarchy, not the same tap again.
- **Scroll the whole form before calling a field missing.** A field seen earlier and gone
  now has scrolled out of view, not disappeared; scroll back to it rather than typing
  into the wrong one.
- **Reason about swipes in screen percentages,** converting with `wm size` at the end, so
  the same gesture works across devices. A swipe pushes the screen: swiping right reveals
  what is to the left.

## Falling back to coordinates

When nothing is addressable, the loop is: screenshot, look at it, act, screenshot again to
confirm the act landed. Never fire a sequence of taps blind.

```sh
adb -s "$SERIAL" shell wm size
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
