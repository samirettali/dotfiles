import { test } from "node:test";
import assert from "node:assert/strict";
import { spawn, execFile } from "node:child_process";
import { promisify } from "node:util";
import { setTimeout as sleep } from "node:timers/promises";
import { fileURLToPath } from "node:url";
import { join } from "node:path";
import { tmpdir } from "node:os";

const exec = promisify(execFile);
const scripts = process.env.BROWSER_SKILL_SCRIPTS;
if (!scripts) throw new Error("Set BROWSER_SKILL_SCRIPTS to the built skill's scripts directory");
const fixture = fileURLToPath(new URL("./test-log.jsonl", import.meta.url));
const run = (name, args = [], env = process.env) => exec(join(scripts, name), args, { env, timeout: 40000 });

test("logs are filtered, bounded, non-destructive and hide headers by default", async () => {
  const args = ["--file", fixture, "--kind", "network", "--status", "401"];
  const first = (await run("logs.js", args)).stdout;
  assert.match(first, /401 GET https:\/\/example.test\/api/);
  assert.doesNotMatch(first, /test-secret/);
  assert.equal((await run("logs.js", args)).stdout, first);
  assert.match((await run("logs.js", [...args, "--headers", "AUTHORIZATION"])).stdout, /test-secret/);
  assert.match((await run("logs.js", ["--file", fixture, "--filter", "TypeError"])).stdout, /TypeError/);
  assert.match((await run("logs.js", ["--file", fixture, "--kind", "network", "--limit", "1"])).stdout, /ERR POST/);
  assert.equal((await run("logs.js", ["--file", fixture, "--since", "2026-01-01T13:00:00Z"])).stdout.trim(), "(empty)");
  const capture = `import {captureHeaders} from ${JSON.stringify(join(scripts, "headers.js"))}; console.log(JSON.stringify(captureHeaders({Authorization:'secret',Cookie:'private','Content-Type':'text/html'})));`;
  assert.equal((await exec(process.execPath, ["--input-type=module", "-e", capture], { env: { ...process.env, BROWSER_LOG_HEADERS: "" } })).stdout.trim(), "{}");
  assert.equal((await exec(process.execPath, ["--input-type=module", "-e", capture], { env: { ...process.env, BROWSER_LOG_HEADERS: "AUTHORIZATION" } })).stdout.trim(), '{"Authorization":"secret"}');
  await assert.rejects(run("logs.js", ["--file", fixture, "--limit", "0"]));
  await assert.rejects(run("logs.js", ["--file", "/nonexistent-browser-log"]));
});

test("CDP interactions and serialized CLI actions", { skip: !process.env.BROWSER_BIN }, async () => {
  const port = 19333;
  const env = { ...process.env, BROWSER_DEBUG_PORT: String(port), BROWSER_ACTION_LOCK_PORT: "49333" };
  let occupied = false;
  try { occupied = (await fetch(`http://localhost:${port}/json/version`)).ok; } catch {}
  assert.equal(occupied, false, "test debug port must not already have a browser");
  const browser = spawn(process.env.BROWSER_BIN, [
    "--headless", "--disable-extensions", "--no-first-run", "--no-default-browser-check",
    `--remote-debugging-port=${port}`, `--user-data-dir=${join(tmpdir(), `browser-skill-test-${process.pid}`)}`,
    "about:blank",
  ], { stdio: "ignore" });
  try {
    let ready = false;
    for (let i = 0; i < 100; i++) {
      try { ready = (await fetch(`http://localhost:${port}/json/version`)).ok; } catch {}
      if (ready) break;
      await sleep(100);
    }
    assert.ok(ready, "browser started");
    const html = `<input id="email" type="email" value="old@example.test"><textarea id="text">old</textarea>
      <button id="go" onclick="window.clicked = true">Go</button>
      <button class="duplicate">A</button><button class="duplicate">B</button>
      <script>window.events=[];for(const kind of ['input','change'])document.addEventListener(kind,e=>events.push([kind,e.isTrusted]));</script>`;
    await run("nav.js", [`data:text/html,${encodeURIComponent(html)}`], env);
    await run("fill.js", ["#email", "new@example.test"], env);
    await run("fill.js", ["#text", ""], env);
    await run("click.js", ["#go"], env);
    const result = await run("eval.js", ["JSON.stringify({email:document.querySelector('#email').value,text:document.querySelector('#text').value,clicked:window.clicked,events})"], env);
    assert.match(result.stdout, /new@example.test/);
    assert.match(result.stdout, /"text":""/);
    assert.match(result.stdout, /"clicked":true/);
    assert.match(result.stdout, /\["input",true\]/);
    assert.match(result.stdout, /\["change",true\]/);
    await assert.rejects(run("click.js", [".duplicate"], env));
    await run("eval.js", ["setTimeout(() => { const b=document.createElement('button'); b.id='delayed'; b.textContent='Delayed'; document.body.append(b); }, 300); 'scheduled'"], env);
    await run("click.js", ["#delayed"], env);
    await run("eval.js", ["window.order=[]; 'ready'"], env);
    await Promise.all([1, 2].map(id => run("eval.js", [`await (async () => { order.push('start${id}'); await new Promise(r=>setTimeout(r,300)); order.push('end${id}'); return 'done'; })()`], env)));
    const order = (await run("eval.js", ["JSON.stringify(order)"], env)).stdout;
    assert.match(order, /start1.*end1.*start2.*end2|start2.*end2.*start1.*end1/);
  } finally {
    browser.kill("SIGTERM");
    await new Promise(resolve => { if (browser.exitCode !== null) resolve(); else browser.once("exit", resolve); });
  }
});
