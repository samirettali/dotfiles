---
name: firefox
description: Drive the user's real Firefox over the Remote Debugging Protocol — list and open tabs, read and manipulate page DOM, screenshot a page, and inspect or restyle the browser's own interface (sidebar, tab strip, toolbar, urlbar, userChrome.css). Unlike a fresh automation browser this is the live profile, with its logins, cookies and extensions. Triggers on Firefox, userChrome.css, gwfox, browser chrome, vertical tabs, sidebar, urlbar, "open a tab in my browser", "what's on the page I have open", "screenshot the page", "why is this space there", "the rule does not apply". For a throwaway browser with no session, use web-browser, which drives Chrome over CDP.
---

# Driving Firefox over RDP

Firefox's DevTools speak a JSON protocol over a TCP port. Anything the Browser Toolbox can
do is reachable from a script: evaluating JS in a page, evaluating JS in the browser's own
chrome, listing and opening tabs, taking screenshots.

Two things make this different from a normal automation browser. It is the **user's real
profile** — logged-in sessions, extensions, history — so it can reach pages a fresh browser
cannot, and anything done here is visible to them. And it can script the **browser UI
itself**, which CDP-style automation cannot touch at all.

## Connecting

`devtools.chrome.enabled` and `devtools.debugger.remote-enabled` are already `true` in
this config. Neither opens anything by itself: the port only exists while Firefox runs
with the flag below.

One pref has to change for the session, in `about:config`:

- `devtools.debugger.prompt-connection` = `false`

It defaults to `true`, which is the right resting state — a dialog then guards every
incoming connection. But **each `rdp.py` invocation opens its own connection**, so
leaving it on means a dialog per command. Set it to `false` while working, and back to
`true` when finished. (A long script can keep one `RDP()` and answer a single prompt,
but the CLI cannot.)

Then quit Firefox and start it with the port open:

```sh
"$HOME/Applications/Home Manager Apps/Firefox.app/Contents/MacOS/firefox" \
  --start-debugger-server 6000 \
  --profile "$HOME/Library/Application Support/Firefox/Profiles/<profile>"
```

The flag is `--start-debugger-server`. `--start-debugging-server` is silently ignored:
Firefox starts normally and nothing listens. Always confirm, because the two look identical
from the outside:

```sh
lsof -iTCP:6000 -sTCP:LISTEN
```

**The port runs code with chrome privileges against a live profile** — cookies, sessions,
an unlocked password vault. It is loopback-only, but with `prompt-connection` off there is
no confirmation step at all. Turn it back to `true` when finished, and never put that one
in a config that is always applied: an agent able to flip it is exactly the reason it
exists.

## The client

`scripts/rdp.py` wraps the protocol. Every common operation is a subcommand, and
`eval` is the escape hatch for anything not covered.

```sh
rdp.py tabs                              # every tab, marked live or zombie
rdp.py open https://example.com          # open one, wait for load, print url/title
rdp.py close example.com                 # close every tab matching url or title
rdp.py goto https://x.com --tab github   # navigate
rdp.py text --tab github                 # page innerText
rdp.py html --tab github                 # page HTML
rdp.py click "button.submit" --tab foo   # click by CSS selector
rdp.py fill "#q" hello --tab foo         # set a value, fire input and change
rdp.py shot out.png --tab foo [--full]   # PNG of the viewport, or the whole page
rdp.py measure "#tabbrowser-tabbox"      # chrome box chain: rects, margins, padding
rdp.py rules "#browser" margin-top       # every rule setting it, in cascade order
rdp.py computed "#browser" margin-top    # just the computed values
rdp.py find "el => el.scrollHeight > el.clientHeight + 4"   # shadow trees included
rdp.py messages [filter]                 # browser console, where silent failures land
rdp.py pref sidebar.visibility [value]   # read or set a pref, live
rdp.py wait "#app" --tab foo             # wait for an element to exist
rdp.py css /path/overrides.css           # (re)apply a stylesheet, no rebuild
rdp.py eval [--tab foo] < code.js        # raw
```

Without `--tab` a command runs in the **browser chrome**; with it, inside that page.

As a library when several steps share a connection:

```python
from rdp import RDP
c = RDP()
c.js("document.title", tab="github")      # in a page
c.js("Services.appinfo.version")          # in the chrome
c.js_await("(async () => …)()")           # anything returning a promise
c.screenshot("out.png", full=True)
c.measure("#sidebar-main")
```

Two protocol details are handled once, in `js` and `js_await`, and are the reason
raw evaluation is awkward:

- `evaluateJSAsync` returns a **promise object**, not what it resolves to. `js_await`
  parks the value on a global and polls for it.
- Values over a few KB come back as a **`longString` reference** — a dict with `actor`
  and `length` — that has to be fetched in slices. Treated as a string it looks like an
  empty result, which reads as a failure when the value was there all along.

For raw `eval`, wrap multi-line code in `(() => { ... })()` and return a string;
`JSON.stringify(..., null, 1)` for anything structured. Objects come back as opaque
actor references.

## Working with pages

The helpers cover the usual path. Below them it is plain DOM access in the page's own
context, so anything else is one `eval` away:

```js
JSON.stringify([...document.querySelectorAll('article')].slice(0, 5).map(a => ({
  who: a.querySelector('[data-testid=User-Name]')?.innerText,
  text: a.innerText.slice(0, 120),
})))
```

Opening and closing tabs goes through the chrome side (`gBrowser.addTab`,
`gBrowser.removeTab`); `open_tab` and `close_tabs` do it and wait for the load. Clean up
tabs opened for a task — this is someone's working browser.

Screenshots go bitmap → canvas → PNG blob → base64 → longString, because the protocol
carries JSON and has no binary channel. `screenshot()` does the whole chain; `--full`
passes a rect the size of `document.scrollHeight` instead of the viewport.

## Working with the browser UI

Without `--tab`, evaluation happens in the chrome document, where `userChrome.css`
applies. This is the part no page-automation tool can reach.

`measure` prints the box chain from an element up to the root, crossing shadow
boundaries — it answers most "where does this empty space come from" questions, and is
far more reliable than reasoning about the stylesheet. `find` walks the same trees
looking for elements matching a predicate, which is how you locate something with no
stable id, like the scroller inside an `arrowscrollbox`.

`rules` is the one to reach for when a rule "does not work". It prints every rule that
matches the element and sets that property, in cascade order, marking `!important`, next
to the computed value — so "my rule is losing to a more specific one" and "my selector
never matched" stop looking the same. Guessing between those two costs hours.

```
$ rdp.py rules "#sidebar-container" margin-top
computed: -39px
! 34px      & #sidebar-main, & #sidebar-container   [userChrome.css]
! -39px     & #sidebar-main, & #sidebar-container   [userChrome.css]
```

`messages` reads the browser console, which is where Firefox reports things it shows
nowhere else — a policy that failed to apply, a stylesheet that failed to parse. A
config change that silently does nothing usually has an explanation waiting there.

`pref` reads and writes prefs live, so a theory about `sidebar.visibility` or a
`gwfox.*` toggle can be tested in a second instead of a rebuild and a restart. Changes
made this way are not persisted by the config that owns them, so treat them as
experiments and put the answer in the repo.

`css` registers a stylesheet immediately, so a change can be seen without a rebuild. It
registers it as a `USER_SHEET`, because that is what `userChrome.css` is. Register it as an
`AUTHOR_SHEET` instead and every override silently loses to the theme: a user `!important`
outranks an author one regardless of specificity, so the rule matches, appears in `rules`,
and still does not apply.

## What bites

- **Most background tabs are `isZombieTab`.** Firefox unloads them, and a zombie cannot be
  attached until something loads it. `console()` skips them, and the helpers that need a
  live page call `select_tab` first.
- **`userChrome.css` is not in `document.styleSheets`.** It is registered through the
  style sheet service, so enumerating the document's sheets finds nothing and every rule
  looks absent. `rules` uses `InspectorUtils.getMatchingCSSRules`, which sees every
  origin; it exists only in the chrome, so pages fall back to the document's sheets.
- **Actor ids belong to one connection.** A descriptor from an earlier `RDP()` is invalid in
  the next one, and fails with `tabDestroyed`, which reads like the tab closed.
- **A live-registered sheet is additive.** It stacks on the `userChrome.css` loaded at
  startup: additions and changes apply, but a *removed* rule stays in force until restart.
  Test additions and edits live; verify removals after a rebuild.
- **`rules` reads longhands, and themes often declare shorthands.** A rule setting
  `margin-block` will not show up when asking about `margin-top`, so a property can look
  unset while something is plainly setting it. When the computed value has no rule behind
  it, ask again for the shorthand.
- **Descendant combinators do not cross shadow boundaries.** `:root:has(…) .buttons-wrapper`
  never matches inside a shadow tree, at any specificity. Write those rules top-level.
- **`visibility: hidden` makes an element unfocusable.** Hiding the urlbar that way means
  cmd+L asks for focus, is refused, and opens a bar with nothing focused. Use `opacity: 0`
  with `pointer-events: none`.
- **`display: none` also drops the element's margins**, which are often what spaced its
  neighbours. `visibility: hidden` keeps the box. Choose per case.
- **CSS nesting can compile to a selector that cannot match.** A rule nested as
  `:root:has(…) &` where `&` already begins with `:root` yields `:root … :root …`, and no
  document has an `html` inside an `html`. Check a rule *can* match before fighting
  specificity.
- **`userChrome.css` and enterprise policies are read only at startup**, so a rebuild that
  changes either needs a restart, from the current bundle.
- Measure before changing and after. A value that looks right in the stylesheet is a
  hypothesis; `getBoundingClientRect()` is the answer.
