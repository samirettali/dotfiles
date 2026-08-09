#!/usr/bin/env python3
"""Drive a running Firefox over the Remote Debugging Protocol.

Start Firefox with --start-debugger-server 6000 first (see SKILL.md), then:

    rdp.py tabs                             list tabs
    rdp.py open https://example.com         open one, print its title
    rdp.py close example.com                close every tab matching
    rdp.py goto https://x.com --tab github  navigate a tab
    rdp.py text --tab github                page innerText
    rdp.py html --tab github                page HTML
    rdp.py click "button.submit" --tab foo  click, by CSS selector
    rdp.py fill "#q" hello --tab foo        set a value and fire input/change
    rdp.py shot out.png [--tab foo] [--full]
    rdp.py measure "#tabbrowser-tabbox"     chrome box chain: rects, margins, padding
    rdp.py rules "#browser" margin-top      every rule setting it, and the computed value
    rdp.py computed "#browser" margin-top   just the computed values
    rdp.py messages [filter]                browser console, where policy/CSS errors land
    rdp.py pref sidebar.visibility [value]  read or set a pref, live
    rdp.py wait "#app" --tab foo            wait for an element
    rdp.py css /path/overrides.css          (re)apply a stylesheet, no rebuild
    rdp.py eval [--tab foo] < code.js       raw escape hatch

Everything the helpers do is also available as a library:

    from rdp import RDP
    c = RDP()
    c.js("document.title", tab="github")     # in a page
    c.js("Services.appinfo.version")         # in the browser chrome
    c.screenshot("out.png", full=True)
"""
import base64
import json
import socket
import sys
import time

# Where a value is parked between the call that produces it and the call that
# reads it, per context. Chrome evals run in a sandbox that does not persist, so
# the browser window is used instead.
CHROME_GLOBAL = "Services.wm.getMostRecentWindow('navigator:browser')"
PAGE_GLOBAL = "window"


class RDPError(RuntimeError):
    pass


class RDP:
    def __init__(self, host="127.0.0.1", port=6000, timeout=30):
        try:
            self.sock = socket.create_connection((host, port), timeout=timeout)
        except OSError as e:
            raise RDPError(
                f"cannot reach {host}:{port} ({e}). Is Firefox running with "
                "--start-debugger-server?"
            ) from e
        self.buf = b""
        self.hello = self.recv()
        self._consoles = {}

    # -- protocol --------------------------------------------------------

    def send(self, packet):
        raw = json.dumps(packet).encode()
        self.sock.sendall(str(len(raw)).encode() + b":" + raw)

    def recv(self):
        while True:
            if b":" in self.buf:
                head, rest = self.buf.split(b":", 1)
                if head.isdigit():
                    n = int(head)
                    if len(rest) >= n:
                        self.buf = rest[n:]
                        return json.loads(rest[:n])
            chunk = self.sock.recv(1 << 16)
            if not chunk:
                raise RDPError("connection closed by the server")
            self.buf += chunk

    def request(self, packet, want=None):
        self.send(packet)
        for _ in range(500):
            msg = self.recv()
            if want is None or want(msg):
                return msg
        raise RDPError(f"no reply matching {packet.get('type')!r}")

    # -- targets ---------------------------------------------------------

    def tabs(self):
        """Every tab. `isZombieTab` ones are unloaded and cannot be attached."""
        return self.request(
            {"to": "root", "type": "listTabs"}, lambda m: "tabs" in m
        )["tabs"]

    def console(self, tab=None):
        """Console actor for a page (`tab` matches url or title) or the chrome."""
        if tab in self._consoles:
            return self._consoles[tab]
        if tab is None:
            proc = self.request(
                {"to": "root", "type": "getProcess", "id": 0},
                lambda m: "processDescriptor" in m or "error" in m,
            )
            if "error" in proc:
                raise RDPError(f"getProcess: {proc}")
            target = self.request(
                {"to": proc["processDescriptor"]["actor"], "type": "getTarget"},
                lambda m: "process" in m or "error" in m,
            )
            if "error" in target:
                raise RDPError(f"getTarget: {target}")
            actor = target["process"]["consoleActor"]
        else:
            actor = None
            for t in self.tabs():
                hay = (t.get("url") or "") + " " + (t.get("title") or "")
                if tab and tab.lower() not in hay.lower():
                    continue
                if t.get("isZombieTab"):
                    continue
                reply = self.request(
                    {"to": t["actor"], "type": "getTarget"},
                    lambda m: "frame" in m or "error" in m,
                )
                if "frame" in reply:
                    actor = reply["frame"]["consoleActor"]
                    break
            if actor is None:
                raise RDPError(
                    f"no live tab matching {tab!r}. Unloaded tabs cannot be "
                    "attached — select it in the browser first."
                )
        self._consoles[tab] = actor
        return actor

    # -- evaluation ------------------------------------------------------

    def _resolve(self, value):
        """Values over a few KB arrive as a `longString` reference, not a string."""
        if not isinstance(value, dict):
            return value
        if value.get("type") == "longString":
            actor, n, out, pos = value["actor"], value["length"], [], 0
            while pos < n:
                end = min(pos + 100_000, n)
                rep = self.request(
                    {"to": actor, "type": "substring", "start": pos, "end": end},
                    lambda m: "substring" in m or "error" in m,
                )
                if "error" in rep:
                    raise RDPError(f"substring: {rep}")
                out.append(rep["substring"])
                pos = end
            return "".join(out)
        if value.get("type") in ("undefined", "null"):
            return None
        return value

    def js(self, code, tab=None):
        """Evaluate and return the value. Objects come back as actor references,
        so return a string — JSON.stringify for anything structured."""
        out = self.request(
            {"to": self.console(tab), "type": "evaluateJSAsync", "text": code},
            lambda m: m.get("type") == "evaluationResult" or "error" in m,
        )
        if out.get("exception"):
            raise RDPError(
                f"JS exception: {self._resolve(out.get('exceptionMessage')) or out['exception']}"
            )
        return self._resolve(out.get("result"))

    def js_await(self, code, tab=None, timeout=30):
        """Evaluate an async expression and wait for it.

        evaluateJSAsync hands back the promise itself rather than what it
        resolves to, so the value is parked on a global and polled for.
        """
        holder = PAGE_GLOBAL if tab is not None else CHROME_GLOBAL
        slot = f"__rdp_{int(time.time() * 1000)}"
        self.js(
            f"""(() => {{
              const g = {holder};
              g.{slot} = undefined;
              Promise.resolve().then(async () => {{
                try {{ g.{slot} = {{ ok: await ({code}) }}; }}
                catch (e) {{ g.{slot} = {{ err: String(e && e.message || e) }}; }}
              }});
              return 'started';
            }})()""",
            tab,
        )
        deadline = time.time() + timeout
        while time.time() < deadline:
            got = self.js(f"(() => {{ const v = {holder}.{slot}; return v === undefined ? '' : JSON.stringify({{done: true}}); }})()", tab)
            if got:
                err = self.js(f"(() => {{ const v = {holder}.{slot}; return v.err || ''; }})()", tab)
                if err:
                    raise RDPError(f"async JS failed: {err}")
                value = self.js(f"{holder}.{slot}.ok", tab)
                self.js(f"delete {holder}.{slot}", tab)
                return value
            time.sleep(0.2)
        raise RDPError(f"timed out after {timeout}s")

    # -- tabs ------------------------------------------------------------

    def open_tab(self, url):
        self.js(
            f"""(() => {{
              const w = {CHROME_GLOBAL};
              const t = w.gBrowser.addTab({json.dumps(url)}, {{
                triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
              }});
              w.gBrowser.selectedTab = t;
              return 'ok';
            }})()"""
        )
        self._consoles.clear()
        return self.wait_for_load()

    def close_tabs(self, match):
        n = self.js(
            f"""(() => {{
              const w = {CHROME_GLOBAL};
              let n = 0;
              for (const t of [...w.gBrowser.tabs]) {{
                const u = t.linkedBrowser.currentURI.spec || '';
                const l = t.label || '';
                if ((u + ' ' + l).toLowerCase().includes({json.dumps(match.lower())})) {{ w.gBrowser.removeTab(t); n++; }}
              }}
              return String(n);
            }})()"""
        )
        self._consoles.clear()
        return int(n)

    def goto(self, url, tab=None):
        if tab is None:
            self.js(
                f"{CHROME_GLOBAL}.gBrowser.selectedBrowser.loadURI("
                f"Services.io.newURI({json.dumps(url)}), "
                "{triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal()})"
            )
        else:
            self.js(f"location.href = {json.dumps(url)}", tab)
        self._consoles.clear()
        return self.wait_for_load()

    def wait_for_load(self, timeout=30):
        deadline = time.time() + timeout
        while time.time() < deadline:
            state = self.js(
                f"""(() => {{
                  const b = {CHROME_GLOBAL}.gBrowser.selectedBrowser;
                  return JSON.stringify({{
                    busy: b.webProgress.isLoadingDocument,
                    url: b.currentURI.spec,
                    title: b.contentTitle || '',
                  }});
                }})()"""
            )
            info = json.loads(state)
            if not info["busy"] and not info["url"].startswith("about:blank"):
                return info
            time.sleep(0.3)
        raise RDPError("page did not finish loading")

    def select_tab(self, match):
        found = self.js(
            f"""(() => {{
              const w = {CHROME_GLOBAL};
              for (const t of w.gBrowser.tabs) {{
                const u = t.linkedBrowser.currentURI.spec || '';
                const l = t.label || '';
                if ((u + ' ' + l).toLowerCase().includes({json.dumps(match.lower())})) {{
                  w.gBrowser.selectedTab = t; return 'ok';
                }}
              }}
              return '';
            }})()"""
        )
        if not found:
            raise RDPError(f"no tab matching {match!r}")
        self._consoles.clear()

    # -- page helpers ----------------------------------------------------

    def text(self, tab=None, limit=None):
        cut = f".slice(0, {int(limit)})" if limit else ""
        return self.js(f"document.body.innerText{cut}", tab)

    def html(self, tab=None):
        return self.js("document.documentElement.outerHTML", tab)

    def click(self, selector, tab=None):
        return self.js(
            f"""(() => {{
              const el = document.querySelector({json.dumps(selector)});
              if (!el) return 'not found';
              el.click();
              return 'clicked';
            }})()""",
            tab,
        )

    def fill(self, selector, value, tab=None):
        return self.js(
            f"""(() => {{
              const el = document.querySelector({json.dumps(selector)});
              if (!el) return 'not found';
              el.focus();
              el.value = {json.dumps(value)};
              el.dispatchEvent(new Event('input', {{bubbles: true}}));
              el.dispatchEvent(new Event('change', {{bubbles: true}}));
              return 'filled';
            }})()""",
            tab,
        )

    def screenshot(self, path, tab=None, full=False):
        """PNG of the selected tab. RDP carries JSON only, so the image goes
        bitmap -> canvas -> blob -> base64 and is read back as a longString."""
        if tab:
            self.select_tab(tab)
        rect = "null"
        if full:
            size = self.js(
                "JSON.stringify({w: document.documentElement.scrollWidth,"
                " h: document.documentElement.scrollHeight})",
                tab or "",
            )
            s = json.loads(size)
            rect = f"new (Services.wm.getMostRecentWindow('navigator:browser')).DOMRect(0, 0, {s['w']}, {s['h']})"
        b64 = self.js_await(
            f"""(async () => {{
              const w = {CHROME_GLOBAL};
              const bc = w.gBrowser.selectedBrowser.browsingContext;
              const bitmap = await bc.currentWindowGlobal.drawSnapshot({rect}, 1, 'white');
              const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
              canvas.getContext('2d').drawImage(bitmap, 0, 0);
              const blob = await canvas.convertToBlob({{type: 'image/png'}});
              const buf = new Uint8Array(await blob.arrayBuffer());
              let bin = '';
              const CH = 0x8000;
              for (let i = 0; i < buf.length; i += CH) {{
                bin += String.fromCharCode.apply(null, buf.subarray(i, i + CH));
              }}
              return btoa(bin);
            }})()"""
        )
        data = base64.b64decode(b64)
        with open(path, "wb") as fh:
            fh.write(data)
        return {"path": path, "bytes": len(data)}

    # -- chrome helpers --------------------------------------------------

    def measure(self, selector):
        """Rects, margins and padding from an element up to the root, crossing
        shadow boundaries. Answers most 'where is this space from' questions."""
        return self.js(
            f"""(() => {{
              const fmt = el => {{
                const cs = getComputedStyle(el), r = el.getBoundingClientRect();
                const cls = String(el.className || '').trim().replace(/\\s+/g, '.');
                return `${{el.localName}}${{el.id ? '#' + el.id : ''}}${{cls ? '.' + cls : ''}}`
                  + ` | top ${{Math.round(r.top)}} h ${{Math.round(r.height)}}`
                  + ` | margin ${{cs.marginTop}}/${{cs.marginBottom}} padding ${{cs.paddingTop}}`
                  + ` | ${{cs.display}} ${{cs.visibility}}`;
              }};
              let el = document.querySelector({json.dumps(selector)});
              if (!el) return 'not found';
              const out = [];
              while (el) {{ out.push(fmt(el)); el = el.parentElement || el.getRootNode().host; }}
              return out.join('\\n');
            }})()"""
        )

    def find(self, predicate):
        """Elements matching a JS predicate, shadow trees included.
        e.g. find("el => el.scrollHeight > el.clientHeight + 4")"""
        return self.js(
            f"""(() => {{
              function* walk(root) {{
                for (const el of root.querySelectorAll('*')) {{
                  yield el;
                  if (el.shadowRoot) yield* walk(el.shadowRoot);
                }}
              }}
              const test = {predicate};
              const out = [];
              for (const el of walk(document)) {{
                if (!test(el)) continue;
                const cls = String(el.className || '').trim().replace(/\\s+/g, '.');
                out.push(`${{el.localName}}${{el.id ? '#' + el.id : ''}}${{cls ? '.' + cls : ''}}`);
              }}
              return out.join('\\n') || 'nothing matched';
            }})()"""
        )

    def rules(self, selector, prop, tab=None):
        """Every rule that matches this element and sets `prop`, in cascade
        order, with its !important flag — plus the computed value.

        Answers "is my rule losing, or does it not match at all", which is the
        question every specificity fight turns on. In the chrome it uses
        InspectorUtils, the only way to see sheets registered through the style
        sheet service: userChrome.css is not in document.styleSheets.
        """
        return self.js(
            f"""(() => {{
              const el = document.querySelector({json.dumps(selector)});
              if (!el) return 'not found';
              const prop = {json.dumps(prop)};
              const out = [];
              const add = r => {{
                const v = r.style && r.style.getPropertyValue(prop);
                if (!v) return;
                out.push((r.style.getPropertyPriority(prop) === 'important' ? '!' : ' ')
                  + ' ' + v.slice(0, 28).padEnd(30)
                  + (r.selectorText || '').slice(0, 90)
                  + (r.parentStyleSheet && r.parentStyleSheet.href
                      ? '   [' + r.parentStyleSheet.href.split('/').pop() + ']' : ''));
              }};
              if (typeof InspectorUtils !== 'undefined' && InspectorUtils.getMatchingCSSRules) {{
                for (const r of InspectorUtils.getMatchingCSSRules(el)) add(r);
              }} else {{
                const walk = list => {{
                  for (const r of list) {{
                    if (r.cssRules) {{ walk(r.cssRules); continue; }}
                    if (!r.selectorText) continue;
                    let hit = false;
                    try {{ hit = el.matches(r.selectorText); }} catch (e) {{ continue; }}
                    if (hit) add(r);
                  }}
                }};
                for (const sh of document.styleSheets) {{
                  try {{ walk(sh.cssRules); }} catch (e) {{}}
                }}
              }}
              const cs = getComputedStyle(el).getPropertyValue(prop);
              return 'computed: ' + cs + '\\n'
                + (out.join('\\n') || '(no matching rule sets it)');
            }})()""",
            tab,
        )

    def computed(self, selector, *props, tab=None):
        """Computed values for one element, without the whole ancestor chain."""
        wanted = json.dumps(list(props))
        return self.js(
            f"""(() => {{
              const el = document.querySelector({json.dumps(selector)});
              if (!el) return 'not found';
              const cs = getComputedStyle(el);
              const o = {{}};
              for (const p of {wanted}) o[p] = cs.getPropertyValue(p);
              return JSON.stringify(o, null, 1);
            }})()""",
            tab,
        )

    def messages(self, limit=40, match=None):
        """Recent browser console messages, newest last.

        This is where Firefox reports things it will not show anywhere else —
        a policy that failed to apply, a CSS file that failed to parse.
        """
        return self.js(
            f"""(() => {{
              const msgs = Services.console.getMessageArray() || [];
              const want = {json.dumps((match or '').lower())};
              return msgs
                .map(m => {{ try {{ return m.message || String(m); }} catch (e) {{ return ''; }} }})
                .filter(t => t && (!want || t.toLowerCase().includes(want)))
                .slice(-{int(limit)})
                .join('\\n');
            }})()"""
        )

    def pref(self, name, value=None):
        """Read or set a pref, without a rebuild and a restart."""
        if value is None:
            return self.js(
                f"""(() => {{
                  const p = Services.prefs, n = {json.dumps(name)};
                  switch (p.getPrefType(n)) {{
                    case p.PREF_BOOL: return 'bool ' + p.getBoolPref(n);
                    case p.PREF_INT: return 'int ' + p.getIntPref(n);
                    case p.PREF_STRING: return 'string ' + p.getStringPref(n);
                    default: return 'unset';
                  }}
                }})()"""
            )
        return self.js(
            f"""(() => {{
              const p = Services.prefs, n = {json.dumps(name)}, v = {json.dumps(value)};
              if (v === 'true' || v === 'false') p.setBoolPref(n, v === 'true');
              else if (/^-?[0-9]+$/.test(v)) p.setIntPref(n, parseInt(v, 10));
              else p.setStringPref(n, v);
              return 'set';
            }})()"""
        )

    def wait_for(self, selector, tab=None, timeout=15):
        """Wait for an element to exist, for pages that render late."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            if self.js(
                f"document.querySelector({json.dumps(selector)}) ? 'y' : ''", tab
            ):
                return True
            time.sleep(0.3)
        raise RDPError(f"{selector!r} never appeared")

    def apply_css(self, path):
        """Register a stylesheet now, at the same cascade origin as userChrome.css.

        USER_SHEET, not AUTHOR_SHEET: userChrome.css is a *user* sheet, and a user
        `!important` outranks an author one whatever the specificity. Registered as
        an author sheet, an override silently loses to the theme it is meant to
        beat — which looks like the rule not matching at all.
        """
        uri = f"file://{path}?v=" + str(int(time.time() * 1000))
        return self.js(
            f"""(() => {{
              const w = {CHROME_GLOBAL};
              const sss = Cc['@mozilla.org/content/style-sheet-service;1']
                .getService(Ci.nsIStyleSheetService);
              if (w.__rdp_sheet) {{
                try {{ sss.unregisterSheet(w.__rdp_sheet, sss.USER_SHEET); }} catch (e) {{}}
              }}
              const uri = Services.io.newURI({json.dumps(uri)});
              sss.loadAndRegisterSheet(uri, sss.USER_SHEET);
              w.__rdp_sheet = uri;
              return 'applied';
            }})()"""
        )


def main(argv):
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__.strip())
        return 0

    cmd, args, tab, full = argv[0], [], None, False
    rest = argv[1:]
    i = 0
    while i < len(rest):
        if rest[i] == "--tab":
            tab = rest[i + 1] if i + 1 < len(rest) else ""
            i += 2
        elif rest[i] == "--full":
            full = True
            i += 1
        else:
            args.append(rest[i])
            i += 1

    c = RDP()
    if cmd == "tabs":
        for t in c.tabs():
            flag = "zombie" if t.get("isZombieTab") else "live  "
            print(f"{flag} {(t.get('title') or '')[:60]:62} {t.get('url') or ''}")
    elif cmd == "open":
        print(json.dumps(c.open_tab(args[0])))
    elif cmd == "close":
        print(f"closed {c.close_tabs(args[0])}")
    elif cmd == "goto":
        print(json.dumps(c.goto(args[0], tab)))
    elif cmd == "text":
        print(c.text(tab, limit=args[0] if args else None))
    elif cmd == "html":
        print(c.html(tab))
    elif cmd == "click":
        print(c.click(args[0], tab))
    elif cmd == "fill":
        print(c.fill(args[0], args[1], tab))
    elif cmd == "shot":
        print(json.dumps(c.screenshot(args[0], tab, full)))
    elif cmd == "measure":
        print(c.measure(args[0]))
    elif cmd == "find":
        print(c.find(args[0]))
    elif cmd == "rules":
        print(c.rules(args[0], args[1], tab))
    elif cmd == "computed":
        print(c.computed(args[0], *args[1:], tab=tab))
    elif cmd == "messages":
        print(c.messages(match=args[0] if args else None))
    elif cmd == "pref":
        print(c.pref(args[0], args[1] if len(args) > 1 else None))
    elif cmd == "wait":
        c.wait_for(args[0], tab)
        print("appeared")
    elif cmd == "css":
        print(c.apply_css(args[0]))
    elif cmd == "eval":
        print(c.js(sys.stdin.read(), tab))
    else:
        print(f"unknown command {cmd!r}; --help for the list", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except RDPError as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(1)
