# Browser skill overlay

`home/packages/ai/coding-agent-skills.nix` builds the pinned `agent-stuff` browser
skill, then layers `home/packages/ai/skills/web-browser/` onto it. Keep this shared
across pi, Claude Code and Codex; do not introduce a separate pi-owned browser.

The overlay deliberately uses the existing CDP client rather than adding
Playwright and a second browser binary. It adds:

- CSS click/fill helpers using Chromium input events, readiness checks and value
  verification. These cover ordinary inputs, not the full Playwright locator API.
- Mutual exclusion around page-touching CLI entry points using an OS-owned
  localhost listening socket. No daemon or stale lock-file recovery is needed.
  This is not FIFO ordering or coordination with MCP; dependent actions must be
  chained and agents must not mix CLI and MCP actions concurrently.
- A streaming, non-destructive log reader with console/network filters, bounded
  request correlation, explicit header display and bounded output.
- Opt-in header capture in the upstream watcher. Headers stay out of logs unless
  explicitly requested at watcher startup; logs containing credentials are
  sensitive. Ordinary CDP events may omit on-wire headers.

Upstream substitutions use `--replace-fail` so a changed watcher fails the build
rather than silently dropping our capture policy. Existing raw log tools remain
unchanged. The appended skill instructions are in `additions.md`.

## Verification

Build only the skill, without activating home-manager:

```sh
nix build --impure --no-link --print-out-paths --expr '
  let
    f = builtins.getFlake (toString ./.);
    pkgs = import f.inputs.nixpkgs { system = builtins.currentSystem; };
  in (import ./home/packages/ai/coding-agent-skills.nix {
    inputs = f.inputs;
    inherit pkgs;
  }).web-browser'
```

Run tests against that output:

```sh
BROWSER_SKILL_SCRIPTS=/nix/store/<output>/scripts \
  node --test home/packages/ai/skills/web-browser/browser.test.mjs
```

Set `BROWSER_BIN` to enable the headless integration test. It uses a temporary
isolated profile, refuses an existing browser on port 19333, and closes its
browser afterwards. Tests cover trusted input/change events, text replacement
and clearing, delayed elements, ambiguous selectors, serialization, filtering,
header opt-in and invalid log arguments. No live user profile is used.
