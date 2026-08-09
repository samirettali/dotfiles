---
name: firefox-ui-debug
description: Inspect and restyle Firefox's own interface — the sidebar, tab strip, toolbar and urlbar — by evaluating JS inside the browser chrome over the Remote Debugging Protocol. Use when working on userChrome.css, a gwfox or Firefox theme, or any question about where a chrome element sits and what is styling it. Triggers on userChrome.css, gwfox, browser chrome, Firefox sidebar, vertical tabs, tab strip, urlbar, browser toolbox, chrome element, sidebar-main, tabbrowser-tabbox, "why is this space there", "the rule does not apply". For automating web *pages* use web-browser instead — that drives Chrome over CDP and cannot see Firefox's UI.
---

# Debugging Firefox's own interface

`userChrome.css` styles a live XUL/HTML document, so the only reliable way to work on it
is to measure that document. Reading the stylesheet and reasoning about what *should*
apply is how you get four rebuilds in a row that each fix the wrong element.

The workflow is: start Firefox with a debugging port, evaluate JS in the parent process
to measure, change the CSS, measure again.

## Setting up the connection

Two prefs, once, in `about:config`:

- `devtools.debugger.remote-enabled` = `true`
- `devtools.debugger.prompt-connection` = `false` — without it every connection opens a
  dialog someone has to click, and the client hangs waiting for it

Then quit Firefox and start it with the port open:

```sh
"$HOME/Applications/Home Manager Apps/Firefox.app/Contents/MacOS/firefox" \
  --start-debugger-server 6000 \
  --profile "$HOME/Library/Application Support/Firefox/Profiles/<profile>"
```

The flag is `--start-debugger-server`. `--start-debugging-server` is silently ignored:
Firefox starts normally and nothing listens.

Confirm before going further, because a wrong flag looks identical to a working launch:

```sh
lsof -iTCP:6000 -sTCP:LISTEN
```

**This port runs code with chrome privileges** against a live profile — cookies, sessions,
an unlocked password vault. It listens on loopback, but with `prompt-connection` off there
is no confirmation step at all. Turn that pref back on when finished, and do not put
either pref in a config that is always applied.

## Evaluating

`scripts/rdp.py` speaks the protocol: it connects, attaches to the parent process target
and evaluates whatever it reads on stdin, in the chrome context of the browser window.

```sh
echo 'document.getElementById("browser").getBoundingClientRect().top' | python3 scripts/rdp.py
```

Return a string — `JSON.stringify(..., null, 1)` for anything structured. Objects come
back as opaque actor references, not values.

Wrap multi-line snippets in `(() => { ... })()`. In a console that keeps its scope between
runs, a bare `const` fails the second time with a redeclaration error.

## Recipes

Measuring a vertical stack. Almost every "where does this empty space come from" question
is answered by walking the ancestor chain and reading rects against margins and padding:

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
the walk stops at the first shadow root and you never see the element that carries the
offset.

Reaching into shadow trees, for anything `querySelectorAll` cannot see:

```js
function* walk(root) {
  for (const el of root.querySelectorAll('*')) {
    yield el;
    if (el.shadowRoot) yield* walk(el.shadowRoot);
  }
}
```

Applying CSS without rebuilding:

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

Use `AUTHOR_SHEET`. `USER_SHEET` sits above author `!important` in the cascade, so rules
that would lose to the theme in production appear to work while testing, and the problem
comes back after the rebuild.

Driving UI state, so a state that needs a mouse can be reached from the keyboard-less
side — opening a sidebar panel, for instance:

```js
Services.wm.getMostRecentWindow('navigator:browser')
  .SidebarController.show('<extension-id>_-sidebar-action')
```

## What bites

- **A live-registered sheet is additive.** It stacks on the `userChrome.css` already
  loaded at startup. Rules that add something work immediately; a *changed* value can
  still lose to the original, and a *removed* rule stays in effect until restart. Test
  additions live, verify removals after a rebuild.
- **Descendant combinators do not cross shadow boundaries.** `:root:has(…) .buttons-wrapper`
  never matches an element inside `sidebar-main`'s shadow tree, no matter the specificity.
  Rules for those elements must be written top-level, exactly as the theme writes its own.
- **`visibility: hidden` makes an element unfocusable.** Hiding the urlbar that way means
  cmd+L asks for focus, is refused, and opens a bar with nothing focused. Use
  `opacity: 0` plus `pointer-events: none`.
- **`display: none` also removes the element's margins**, which are often what spaces its
  neighbours. `visibility: hidden` keeps the box; pick per case, deliberately.
- **CSS nesting can compile to a selector that never matches.** A theme rule nested as
  `:root:has(…) &` where `&` already starts with `:root` produces `:root … :root …`, and no
  document has an `html` inside an `html`. Before fighting specificity, check the rule can
  match at all.
- **`userChrome.css` and enterprise policies are read only at startup.** A rebuild that
  changes either needs Firefox restarted, from the current bundle — see the LaunchServices
  note in the dotfiles `AGENTS.md`.
- Measure before changing, and after. A value that looks right in the stylesheet is a
  hypothesis; `getBoundingClientRect()` is the answer.
