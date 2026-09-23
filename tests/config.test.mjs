import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { test } from "node:test";

const evaluate = (file, attribute) => JSON.parse(execFileSync("nix", [
  "eval", "--impure", "--json", "--expr",
  // Every argument the module declares, stubbed: a new one no longer breaks the test.
  `(let f = import ${resolve(file)}; in f (builtins.mapAttrs (_: _: {}) (builtins.functionArgs f))).${attribute}`,
], { encoding: "utf8" }));
const functions = evaluate("home/packages/shell/fish.nix", "programs.fish.functions");
const functionsSource = Object.entries(functions).map(([name, body]) => `function ${name}\n${body}\nend`).join("\n");
const fish = code => execFileSync("fish", ["--no-config", "-c", `${functionsSource}\n${code}`], {
  encoding: "utf8", env: { ...process.env, TERM: "xterm-256color", SSH_CLIENT: "", SSH_TTY: "" },
});

// Deterministic prompt dependencies, while exercising the actual Nix function bodies.
const stubs = `
function set_color; printf '%s' '<color>'; end
function fish_is_root_user; return 1; end
function fish_git_prompt; printf '%s' '[feature/100%ready]'; end
function prompt_pwd; printf '%s' '100%ready'; end
set -e SSH_CLIENT SSH_TTY IN_NIX_SHELL
set -g CMD_DURATION 1234
`;

test("Fish prompts retain status, spacing, percent signs and transient behavior", () => {
  const prompt = code => fish(`${stubs}\n${code}`).replaceAll("<color>", "");
  assert.equal(prompt("fish_prompt"), "100%ready$ ");
  assert.equal(prompt("true; fish_right_prompt"), "1.23s [feature/100%ready]");
  assert.equal(prompt("false; fish_right_prompt"), "1.23s (1) [feature/100%ready]");
  assert.equal(prompt("function fail; return 42; end; fail; fish_right_prompt"), "1.23s (42) [feature/100%ready]");
  assert.equal(prompt("false; fish_right_prompt --final-rendering"), "");
  assert.equal(prompt("set CMD_DURATION 5; true; fish_right_prompt"), "5ms [feature/100%ready]");
  assert.equal(prompt("set CMD_DURATION 61000; true; fish_right_prompt"), "1m1s [feature/100%ready]");
  assert.equal(prompt("set CMD_DURATION 3661000; true; fish_right_prompt"), "1h1m [feature/100%ready]");
  assert.ok(!Object.hasOwn(functions, "le"));
});

test("Fish colors survive percent signs in real paths and branches", () => {
  const dir = mkdtempSync(join(tmpdir(), "fish-100%ready-"));
  try {
    const git = (...args) => execFileSync("git", ["-C", dir, ...args]);
    git("init", "-q");
    git("symbolic-ref", "HEAD", "refs/heads/feature/100%ready");
    const output = fish(`set -e SSH_CLIENT SSH_TTY IN_NIX_SHELL\ncd '${dir}'\nset CMD_DURATION 42\nfalse; fish_right_prompt\nfish_prompt`);
    assert.match(output, /100%ready/);
    assert.match(output, /\(1\)/);
    assert.match(output, /\u001b\[/);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("Git ignores secrets, but permits explicit safe configuration names", () => {
  const ignores = evaluate("home/packages/shell/git.nix", "programs.git.ignores");
  const dir = mkdtempSync(join(tmpdir(), "git-ignore-"));
  try {
    const ignoreFile = join(dir, "global-ignore");
    writeFileSync(ignoreFile, `${ignores.join("\n")}\n`);
    execFileSync("git", ["init", "-q", dir]);
    for (const [file, ignored] of [
      [".env", true], [".env.local", true], [".env.production", true],
      ["service.env", true], ["sub/.env.local", true], [".envrc.local", true],
      [".envrc", false], [".env.example", false], [".env.sample", false],
      [".env.template", false], ["sub/.env.example", false],
      [".env.example.local", true],
    ]) {
      const result = spawnSync("git", ["-C", dir, "-c", `core.excludesFile=${ignoreFile}`, "check-ignore", "-q", "--", file]);
      assert.equal(result.status, ignored ? 0 : 1, file);
    }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("gd has one owner: the native buffer-local LSP mapping", () => {
  const snacks = readFileSync("home/dotfiles/nvim/lua/plugins/snacks.lua", "utf8");
  const lsp = readFileSync("home/dotfiles/nvim/lua/autocmds/lsp.lua", "utf8");
  assert.doesNotMatch(snacks, /keymap\.set\("n", "gd"/);
  assert.match(lsp, /keymap\.set\("n", "gd", vim\.lsp\.buf\.definition, \{ buffer = ev\.buf/);
});
