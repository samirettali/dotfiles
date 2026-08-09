---
name: firefox-ui-debug
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

Two prefs, once, in `about:config`:

- `devtools.debugger.remote-enabled` = `true`
- `devtools.debugger.prompt-connection` = `false` — otherwise every connection opens a
  dialog someone has to click, and the client hangs waiting

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

**The port runs code with chrome privileges against a live profile** — cookies, sessions, an
unlocked password vault. It is loopback-only, but with `prompt-connection` off there is no
confirmation step. Turn that pref back on when finished, and keep neither pref in a config
that is always applied.

## The client

`scripts/rdp.py` connects, attaches to a target and evaluates JS.

```sh
echo 'document.title' | python3 scripts/rdp.py                # browser chrome
echo 'document.title' | python3 scripts/rdp.py --tab github   # first live tab matching
```

As a library, when more than one round trip is needed:

```python
from rdp import RDP
c = RDP()
c.eval(c.parent_console(), "...")            # the browser UI
c.eval(c.tab_console("example.com"), "...")  # a page
c.tabs()                                     # every tab, with url/title/isZombieTab
```

Wrap multi-line snippets in `(() => { ... })()` and return a string;
`JSON.stringify(..., null, 1)` for anything structured. Objects come back as opaque actor
references, not values.

## Working with pages

Reading a page is just DOM access in its own context:

```js
JSON.stringify({
  url: location.href,
  title: document.title,
  heading: document.querySelector('h1')?.textContent?.trim(),
  text: document.body.innerText.slice(0, 2000),
})
```

The same channel clicks, fills and submits — `el.click()`, `input.value = x` plus an
`input`/`change` event, `form.submit()`.

Opening a tab happens from the chrome side, then attach to it once it has loaded:

```js
(() => {
  const w = Services.wm.getMostRecentWindow('navigator:browser');
  const t = w.gBrowser.addTab('https://example.com', {
    triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
  });
  w.gBrowser.selectedTab = t;
  return 'ok';
})()
```

Close it again with `w.gBrowser.removeTab(t)`. Clean up tabs opened for a task: this is
someone's working browser.

Screenshotting the selected tab. `drawSnapshot` returns a promise, and `evaluateJSAsync`
hands back the promise rather than its value, so park the result on a global and read it on
a second call:

```js
(() => {
  const w = Services.wm.getMostRecentWindow('navigator:browser');
  w.__shot = null;
  (async () => {
    const bc = w.gBrowser.selectedBrowser.browsingContext;
    const bitmap = await bc.currentWindowGlobal.drawSnapshot(null, 1, 'white');
    const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
    canvas.getContext('2d').drawImage(bitmap, 0, 0);
    const buf = new Uint8Array(await (await canvas.convertToBlob({ type: 'image/png' })).arrayBuffer());
    let bin = '', CH = 0x8000;
    for (let i = 0; i < buf.length; i += CH) bin += String.fromCharCode.apply(null, buf.subarray(i, i + CH));
    w.__shot = btoa(bin);
  })();
  return 'started';
})()
```

Then read `w.__shot`, decode the base64 and write a `.png`. **A long return value comes back
as a `longString` grip, not a string** — a dict with `actor` and `length` — and has to be
fetched in slices with `{"to": actor, "type": "substring", "start": …, "end": …}`. Treating
it as a string silently looks like an empty result, which reads as "the screenshot failed"
when in fact it was ready.

## Working with the browser UI

`parent_console()` evaluates in the chrome document, where `userChrome.css` applies. This is
the part no page-automation tool can reach.

Measuring a vertical stack answers most "where does this empty space come from" questions,
and is far more reliable than reasoning about the stylesheet:

```js
(() => {
  const fmt = el => {
    const cs = getComputedStyle(el), r = el.getBoundingClientRect();
    const cls = String(el.className || '').trim().replace(/\s+/g, '.');
    return `${el.localName}${el.id ? '#' + el.id : ''}${cls ? '.' + cls : ''} | top ${Math.round(r.top)} h ${Math.round(r.height)} | margin ${cs.marginTop}/${cs.marginBottom} padding ${cs.paddingTop} | ${cs.display} ${cs.visibility}`;
  };
  let el = document.querySelector('#tabbrowser-tabbox'), out = [];
  while (el) { out.push(fmt(el)); el = el.parentElement || el.getRootNode().host; }
  return out.join('\n');
})()
```

`el.parentElement || el.getRootNode().host` is what crosses shadow boundaries; without it
the walk stops at the first shadow root, which is usually where the answer was.

To reach elements `querySelectorAll` cannot see:

```js
function* walk(root) {
  for (const el of root.querySelectorAll('*')) {
    yield el;
    if (el.shadowRoot) yield* walk(el.shadowRoot);
  }
}
```

Applying CSS without a rebuild:

```js
(() => {
  const w = Services.wm.getMostRecentWindow('navigator:browser');
  const sss = Cc['@mozilla.org/content/style-sheet-service;1'].getService(Ci.nsIStyleSheetService);
  if (w.__ovr) { try { sss.unregisterSheet(w.__ovr, sss.AUTHOR_SHEET); } catch (e) {} }
  const uri = Services.io.newURI('file:///absolute/path/overrides.css?v=' + Date.now());
  sss.loadAndRegisterSheet(uri, sss.AUTHOR_SHEET);
  w.__ovr = uri;
  return 'ok';
})()
```

Use `AUTHOR_SHEET`. `USER_SHEET` outranks author `!important`, so rules that would lose to
the theme in production appear to work while testing and break after the rebuild.

## What bites

- **Most background tabs are `isZombieTab`.** Firefox unloads them, and a zombie cannot be
  attached until something loads it. `tab_console()` skips them; if nothing matches, select
  the tab first.
- **Actor ids belong to one connection.** A descriptor from an earlier `RDP()` is invalid in
  the next one, and fails with `tabDestroyed`, which reads like the tab closed.
- **A live-registered sheet is additive.** It stacks on the `userChrome.css` loaded at
  startup: additions apply at once, a *changed* value can still lose to the original, and a
  *removed* rule stays until restart. Test additions live, verify removals after a rebuild.
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
