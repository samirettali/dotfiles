#!/usr/bin/env node
// Drive Samir's own running browser over one persistent CDP connection.
//
// A browser whose remote debugging was enabled from chrome://inspect exposes only
// the WebSocket named in DevToolsActivePort, with no /json endpoints, and asks the
// user to allow every new connection. `serve` opens that connection once and
// accepts commands on a unix socket, so the user allows it a single time.
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";

const profileDir = process.env.BROWSER_PROFILE_DIR ??
  path.join(os.homedir(), "Library/Application Support/net.imput.helium");
const sock = process.env.BROWSER_LIVE_SOCKET ?? path.join(os.tmpdir(), "agent-web-live.sock");
const idleMs = Number(process.env.BROWSER_LIVE_IDLE_MS ?? 30 * 60 * 1000);
const usage = `Usage:
  live.js serve                     hold the connection (run in the background)
  live.js stop                      close it
  live.js targets                   list open tabs: <targetId> <url>
  live.js <tab> text                URL and visible text
  live.js <tab> shot <file.png>     viewport screenshot
  live.js <tab> click <text> [nth]  click the innermost element with this exact text or aria-label
  live.js <tab> clicksel <css>      click the element matching a CSS selector
  live.js <tab> type <text>         insert text into the focused element
  live.js <tab> key <Key>           press Enter, Tab, Escape, Backspace...
  live.js <tab> eval <js>           evaluate and print the JSON result
  live.js <tab> nav <url>           navigate
<tab> is a targetId or a substring of the tab's URL.`;

const [cmd, ...rest] = process.argv.slice(2);
if (!cmd || cmd === "-h" || cmd === "--help") {
  console.log(usage);
} else if (cmd === "serve") {
  serve();
} else {
  const body = cmd === "stop" || cmd === "targets"
    ? { op: cmd }
    : { tab: cmd, op: rest[0], args: rest.slice(1) };
  const req = http.request({ socketPath: sock, method: "POST", path: "/" }, (res) => {
    let out = "";
    res.on("data", (c) => (out += c));
    res.on("end", () => {
      process.stdout.write(out);
      if (res.statusCode !== 200) process.exitCode = 1;
    });
  });
  req.on("error", (e) => {
    console.error(`No live connection on ${sock} (${e.code}). Start one with: live.js serve`);
    process.exitCode = 1;
  });
  req.end(JSON.stringify(body));
}

function serve() {
  const [port, wsPath] = fs.readFileSync(path.join(profileDir, "DevToolsActivePort"), "utf8").trim().split("\n");
  const ws = new WebSocket(`ws://127.0.0.1:${port}${wsPath}`);
  const pending = new Map();
  const sessions = new Map();
  let id = 0;
  let idle;
  const raw = (method, params = {}, sessionId) => new Promise((resolve, reject) => {
    const i = ++id;
    pending.set(i, { resolve, reject });
    ws.send(JSON.stringify({ id: i, method, params, sessionId }));
  });
  const resetIdle = () => {
    clearTimeout(idle);
    idle = setTimeout(() => ws.close(), idleMs);
  };

  ws.onmessage = (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) {
      const p = pending.get(m.id);
      pending.delete(m.id);
      m.error ? p.reject(new Error(JSON.stringify(m.error))) : p.resolve(m.result);
    } else if (m.method === "Target.detachedFromTarget") {
      for (const [t, s] of sessions) if (s === m.params.sessionId) sessions.delete(t);
    }
  };
  ws.onerror = (e) => {
    console.error("WebSocket error", e.message ?? "", "(was the connection refused in the browser?)");
    process.exit(1);
  };
  ws.onclose = () => {
    fs.rmSync(sock, { force: true });
    console.log("connection closed");
    process.exit(0);
  };

  const pages = async () => (await raw("Target.getTargets")).targetInfos.filter((t) => t.type === "page");
  async function session(tab) {
    const all = await pages();
    const matches = all.filter((t) => t.targetId === tab || t.url.includes(tab));
    if (matches.length !== 1) throw new Error(`${matches.length} tabs match ${tab}`);
    const { targetId } = matches[0];
    if (!sessions.has(targetId)) {
      sessions.set(targetId, (await raw("Target.attachToTarget", { targetId, flatten: true })).sessionId);
    }
    return sessions.get(targetId);
  }

  async function run({ tab, op, args = [] }) {
    if (op === "stop") return setTimeout(() => ws.close(), 50), "closing";
    if (op === "targets") return (await pages()).map((t) => `${t.targetId} ${t.url}`).join("\n");
    const sid = await session(tab);
    const send = (method, params) => raw(method, params, sid);
    const evaluate = async (expression) => {
      const r = await send("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true });
      if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description ?? r.exceptionDetails.text);
      return r.result.value;
    };
    const clickAt = async ({ x, y }) => {
      for (const type of ["mouseMoved", "mousePressed", "mouseReleased"]) {
        await send("Input.dispatchMouseEvent", { type, x, y, button: "left", clickCount: 1 });
      }
    };
    const centre = (find) => `(() => {
      const e = ${find};
      if (!e) return null;
      e.scrollIntoView({ block: "center" });
      const r = e.getBoundingClientRect();
      return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
    })()`;
    const byText = (text, nth) => `(() => {
      const want = ${JSON.stringify(text)}.trim().toLowerCase();
      const label = (e) => (e.innerText || e.value || e.getAttribute("aria-label") || e.placeholder || "").trim().toLowerCase();
      const hits = [...document.querySelectorAll("*")].filter((e) => {
        const r = e.getBoundingClientRect();
        return r.width && r.height && label(e) === want;
      });
      return hits.filter((e) => !hits.some((o) => o !== e && e.contains(o)))[${nth}];
    })()`;

    switch (op) {
      case "text":
        return evaluate(`location.href + "\\n" + document.body.innerText`);
      case "shot": {
        const r = await send("Page.captureScreenshot", { format: "png" });
        fs.writeFileSync(args[0], Buffer.from(r.data, "base64"));
        return args[0];
      }
      case "click":
      case "clicksel": {
        const find = op === "click" ? byText(args[0], Number(args[1] ?? 0)) : `document.querySelector(${JSON.stringify(args[0])})`;
        const point = await evaluate(centre(find));
        if (!point) throw new Error(`not found: ${args[0]}`);
        await clickAt(point);
        return `clicked ${args[0]}`;
      }
      case "type":
        await send("Input.insertText", { text: args[0] });
        return "typed";
      case "key": {
        const code = { Enter: 13, Tab: 9, Backspace: 8, Escape: 27 }[args[0]];
        for (const type of ["keyDown", "keyUp"]) {
          await send("Input.dispatchKeyEvent", { type, key: args[0], code: args[0], windowsVirtualKeyCode: code });
        }
        return `pressed ${args[0]}`;
      }
      case "eval":
        return JSON.stringify(await evaluate(args[0]), null, 1);
      case "nav":
        await send("Page.navigate", { url: args[0] });
        return `navigated to ${args[0]}`;
      default:
        throw new Error(`unknown op ${op}\n${usage}`);
    }
  }

  ws.onopen = () => {
    fs.rmSync(sock, { force: true });
    http.createServer((req, res) => {
      let body = "";
      req.on("data", (c) => (body += c));
      req.on("end", async () => {
        resetIdle();
        try {
          res.end(`${await run(JSON.parse(body))}\n`);
        } catch (e) {
          res.statusCode = 500;
          res.end(`ERROR ${e.message}\n`);
        }
      });
    }).listen(sock, () => {
      resetIdle();
      console.log(`ready on ${sock}`);
    });
  };
}
