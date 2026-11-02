import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, relative, resolve } from "node:path";
import { test } from "node:test";

const script = resolve("claude-cloud/setup.sh");
const rendered = resolve("claude-cloud/home");
const ai = resolve("home/packages/ai");
const read = (path) => readFileSync(path, "utf8");

const files = (dir) =>
  readdirSync(dir, { recursive: true, withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => relative(dir, join(entry.parentPath, entry.name)))
    .sort();

test("the cloud setup installs the render and builds CLAUDE.md as agents.nix does", () => {
  const home = mkdtempSync(join(tmpdir(), "claude-cloud-"));
  try {
    const result = spawnSync("bash", [script], { env: { ...process.env, HOME: home, CLAUDE_CLOUD_NO_INSTALL: "1" }, encoding: "utf8" });
    assert.equal(result.status, 0, result.stderr);

    for (const path of files(rendered)) {
      if (path === ".claude/settings.json") continue;
      assert.equal(read(join(home, path)), read(join(rendered, path)), path);
    }

    // The render plus the tailnet's SessionStart hook, which only cloud
    // sessions get.
    const hook = join(home, ".claude/hooks/tailscale.sh");
    const { hooks, ...settings } = JSON.parse(read(join(home, ".claude/settings.json")));
    assert.deepEqual(settings, JSON.parse(read(join(rendered, ".claude/settings.json"))));
    assert.deepEqual(hooks, { SessionStart: [{ hooks: [{ type: "command", command: hook, timeout: 60 }] }] });
    assert.equal(read(hook), read(resolve("claude-cloud/tailscale.sh")));
    assert.match(read(join(home, ".ssh/config")), /^Host vega\n {4}User samir\n {4}ProxyCommand tailscale nc %h %p\n/m);

    // agents.nix: agents.md, then personal.md, projects.md and the machine
    // file under "This machine".
    const expected =
      read(join(ai, "agents.md")) +
      `\n${read(join(ai, "personal.md"))}\n${read(join(ai, "projects.md"))}\n## This machine\n\n` +
      read(join(ai, "machines/claude-cloud.md"));
    assert.equal(read(join(home, ".claude/CLAUDE.md")), expected);
  } finally {
    rmSync(home, { recursive: true, force: true });
  }
});

test("the cloud settings run no script built for mbp and keep Claude Code's web tools", () => {
  const settings = JSON.parse(read(join(rendered, ".claude/settings.json")));
  assert.equal(settings.statusLine, undefined);
  assert.equal(settings.hooks, undefined);
  assert.equal(settings.disableClaudeAiConnectors, undefined);
  assert.equal(settings.attribution.sessionUrl, false);
  for (const tool of ["WebSearch", "WebFetch"]) {
    assert.ok(!settings.permissions.deny.includes(tool), tool);
  }
  assert.ok(files(join(rendered, ".claude/skills")).includes("review-loop/SKILL.md"));
});
