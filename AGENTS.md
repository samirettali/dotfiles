# AGENTS.md

Nix (flake) dotfiles managing macOS (nix-darwin) and NixOS via home-manager.
Hosts: `mbp` (darwin), `xps` (nixos), `andromeda` (server, home-manager only).

## Commands

- `make build` — rebuild current host (`nh darwin switch .` on macOS, `nixos-rebuild` on NixOS).
- `make fmt` — format all nix with `alejandra`. Run before committing.
- `make check` — `nix flake check`.
- `make update` — `nix flake update`.

Eval a single option without building:
```
nix eval '.#darwinConfigurations.mbp.config.home-manager.users.samir.<option>'
```
The `warning: Git tree ... is dirty` line during eval is benign.

## Conventions

- **Commits:** Conventional Commits, lowercase short subject; add a longer body only
  when it adds useful context, otherwise subject alone.
  `type(scope): subject` — types seen: `feat`, `fix`, `chore`, `refactor`.
- **Format edited `.nix` files with `alejandra` before committing** (`make fmt`).
- **New files are invisible to the flake until staged** (flake reads the git tree).
  Run `git add -N <file>` before `nix eval`/`flake lock`, or eval fails to find it.
- **Never use `mkOutOfStoreSymlink` or symlinks to non-store paths** unless Samir agrees —
  use standard in-store `home.file` / module options.
- Keep comments sparse; the user dislikes noise.

## Structure

- `flake.nix` — inputs + per-host wiring via `mkHomeManagerConfig`. `inputs` is
  threaded into home-manager modules through `extraSpecialArgs`.
- `machines/<host>.nix` — host/system config.
- `home/` — user config. `home/packages/{shell,dev,desktop}/` use **one file per tool**,
  imported from each dir's `default.nix`.
- **Features** (`rust`, `go`, `js`, `python`, …) are passed per-host via
  `mkHomeManagerConfig { features = ...; }`, defaulting to `defaultFeatures` in `flake.nix`.
  `js`/`python` are tri-state strings (`false` | `"minimal"` | `"full"`), the rest are bools.
- **NUR packages:** use the `nurPkgs` specialArg (`nurPkgs.<pkg>`), not the long
  `samirettali-nur.packages.${system}` expression.

## Adding packages

- If a package has a home-manager `programs.<name>` / `services.<name>` module, **prefer the
  module** over a raw `home.packages` entry — new file in `home/packages/shell/<name>.nix`,
  add it to the dir's `default.nix` imports.
- The user keeps unused packages commented in `home/packages/shell/default.nix` on purpose
  (as a "these exist" memo) — don't delete those comments.

## Skills (Claude Code / Codex / pi)

- Shared skill set lives in `home/packages/ai/coding-agent-skills.nix` (one source of
  truth: `{ name = dir-with-SKILL.md; }`); each agent materializes it into its own path.
- External skills are pinned as `flake = false` inputs; `nix flake update` bumps them.
- Repo-local skills live in `.agents/skills/<name>/` (the standard path pi reads) with a
  symlink from `.claude/skills/<name>` for Claude Code. See `.agents/skills/add-skill`.

## Agent bus (cross-session messaging)

`home/packages/ai/agent-bus/` lets one agent session message another (pi ↔ Claude Code).
`bus.ts` is shared verbatim by both sides — nix copies it into the pi extension dir *and*
into the CLI's store dir, so edit it in one place only.

- **Delivery is end-of-turn, by design.** pi uses `sendUserMessage(..., deliverAs: "followUp")`;
  flip `DELIVER_AS` to `"steer"` for mid-turn interrupts. Claude has no mid-turn equivalent
  short of a PostToolUse hook on every tool call.
- **Claude Stop hook must use `hookSpecificOutput.additionalContext`, not `decision: "block"`** —
  `block` shows the reason to the *user* and ends the turn; Claude never sees it.
- **Session ids are sha256-hashed, not sliced.** pi session files are
  `<timestamp>_<uuid>.jsonl`, so any raw prefix collides across all sessions started the same day.
- **Liveness is by pid**, walked up the process tree from the hook (hooks are short-lived
  grandchildren, so their own pid is useless). SessionEnd unregisters the clean case.
- `pi --list-models` does *not* load extensions — a broken extension produces no error there.
  Test extension changes with a real `pi -p` session.

## Gotchas

- **`xps` full eval / `nix flake check` currently fails** on a pre-existing nixpkgs
  insecure-package gate (`nodejs-slim`), unrelated to most changes. `mbp` evaluates clean.
- **Verify tool config against the installed version, not memory** — e.g. lazygit moved
  `git.paging` → `git.pagers` (array); difftastic's HM module writes `programs.git.enable`,
  so gating `difftastic.enable` on `config.programs.git.enable` causes infinite recursion.
