import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { test } from "node:test";

const script = resolve("scripts/check-nix.sh");
test("checks see only current Git files, including intent-to-add and spaced names", () => {
  const dir = mkdtempSync(join(tmpdir(), "nix-files-"));
  const options = { cwd: dir, encoding: "utf8" };
  try {
    execFileSync("git", ["init", "-q"], options);
    writeFileSync(join(dir, "with space.nix"), "{a = 1;}\n");
    execFileSync("git", ["add", "-N", "--", "with space.nix"], options);
    for (const path of [".delta/worktrees/task", ".claude/worktrees/task", "result", "machines/xps"]) {
      mkdirSync(join(dir, path), { recursive: true });
      writeFileSync(join(dir, path, "broken.nix"), "not { valid nix");
    }
    execFileSync("git", ["add", "machines/xps/broken.nix"], options);
    writeFileSync(join(dir, "untracked.nix"), "invalid {");
    writeFileSync(join(dir, "deleted.nix"), "{a = 1;}\n");
    execFileSync("git", ["add", "deleted.nix"], options);
    rmSync(join(dir, "deleted.nix"));
    for (const mode of ["fmt-check", "lint", "fmt"]) {
      const result = spawnSync("bash", [script, mode], options);
      assert.equal(result.status, 0, `${mode}: ${result.stderr}`);
    }
    writeFileSync(join(dir, "with space.nix"), "let unused = 1; in {}\n");
    assert.notEqual(spawnSync("bash", [script, "lint"], options).status, 0);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
