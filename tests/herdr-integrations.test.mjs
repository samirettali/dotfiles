import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { promisify } from "node:util";

const exec = promisify(execFile);
const source = process.env.HERDR_SOURCE;
if (!source) throw new Error("HERDR_SOURCE must name the pinned fork source");

for (const agent of ["claude", "codex", "grok"]) {
  test(`${agent}: SessionStart reports to an isolated Herdr socket`, async () => {
    const dir = await mkdtemp(join(tmpdir(), "hd-"));
    const socket = join(dir, "s");
    const messages = [];
    const server = createServer(connection => {
      let buffer = "";
      connection.on("data", chunk => {
        buffer += chunk;
        if (buffer.includes("\n")) {
          messages.push(JSON.parse(buffer.trim()));
          connection.end('{}\n');
        }
      });
    });
    await new Promise((resolve, reject) => {
      server.once("error", reject);
      server.listen(socket, resolve);
    });
    try {
      const env = { ...process.env, HERDR_ENV: "1", HERDR_PANE_ID: "test-pane", HERDR_SOCKET_PATH: socket };
      delete env.CODEX_THREAD_ID;
      delete env.GROK_SESSION_ID;
      delete env.CURSOR_VERSION;
      const hook = join(source, "src/integration/assets", agent, "herdr-agent-state.sh");
      const run = async event => {
        // execFile's promisified return also exposes the child to write stdin.
        const result = exec("sh", [hook, "session"], { env, timeout: 5000 });
        result.child.stdin.end(JSON.stringify({ hook_event_name: event, session_id: "fixture-session", transcript_path: "/tmp/fixture-session.jsonl" }));
        await result;
      };
      await run("SessionStart");
      assert.equal(messages.length, 1);
      assert.equal(messages[0].method, "pane.report_agent_session");
      assert.equal(messages[0].params.agent, agent);
      assert.equal(messages[0].params.pane_id, "test-pane");
      assert.equal(messages[0].params.agent_session_id, "fixture-session");
      await run("Stop");
      assert.equal(messages.length, 1, "unregistered lifecycle events must not report");
    } finally {
      await new Promise(resolve => server.close(resolve));
      await rm(dir, { recursive: true, force: true });
    }
  });
}
