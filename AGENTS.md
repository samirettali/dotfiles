# AGENTS.md

Nix (flake) dotfiles managing macOS (nix-darwin) and NixOS via home-manager.
Hosts: `mbp` (darwin), `xps` (nixos), `andromeda` (server, home-manager only).

## Commands

- `make build` — rebuild current host (`nh darwin switch .` on macOS, `nixos-rebuild` on NixOS).
- `make fmt` — format all nix with `alejandra`. Run before committing.
- `make check` — `nix flake check`.
- `make models` — refresh the pinned OpenRouter provider limits in
  `home/packages/ai/pi-coding-agent/models.json` (see below); writes the file, then `make build`.
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

## pi model configuration (`pi-models`)

`home/packages/ai/pi-coding-agent/models.json` is the single source of truth. `default.nix`
reads it with `fromJSON` and renders two files: `enabledModels` into `~/.pi/agent/settings.json`
and `providers` into `~/.pi/agent/models.json`. Both are store symlinks, so edit the repo file
and `make build` — never the deployed copies.

`pi-models` (`home/packages/shell/scripts/pi-models/`) edits that file: a Node server on a
random localhost port serving a single `app.html`, opened in the browser and stopped with
ctrl-c. Saving writes the repo file only; applying is still `make build`.

`pi-models --sync` (wired as `make models`) re-fetches the endpoints of every model that pins a
provider and rewrites only the limits that changed, printing a diff. It is the answer to
per-provider limits going stale: a pinned `contextWindow`/`maxTokens` is a snapshot, and nothing
in pi or OpenRouter refreshes it. If the pinned provider is gone it says so and changes nothing,
rather than silently falling back to another one.

Per pi's `docs/models.md`, a custom model in `models[]` with the same id *replaces* the built-in
entry and drops its pricing and metadata, while `modelOverrides` merges on top. Built-in
providers (those in `~/.pi/agent/models-store.json`) therefore use `modelOverrides`; `models[]`
is only for genuinely custom ones like lmstudio.

Per-provider limits come from the per-model `endpoints` call, not `/api/v1/models` — the latter's
`top_provider` describes whichever provider OpenRouter ranks first, which is wrong as soon as
`openRouterRouting.only` pins a different one. The endpoint `tag` is `provider/quant`
(`novita/fp8`); a bare `only: ["novita"]` accepts any quantization from that provider.

## Spoken responses (`speak`)

`speak` (`home/packages/shell/scripts/speak.py`) streams text to ElevenLabs and plays audio
while it is still being generated. The pi extension `speak.ts` is a thin pipe: it forwards
assistant `text_delta` events into `speak --stream` and owns nothing else. Toggle with
`/speak`; defaults from `PI_SPEAK`, voice/model from `SPEAK_VOICE` / `SPEAK_MODEL`.

Decisions worth not re-deriving:

- **Websocket `stream-input` with `auto_mode=true`**, not the HTTP `/stream` endpoint. One
  connection per turn gives gapless audio; a request per sentence would produce audible seams
  and re-pay latency each time. `auto_mode` lets ElevenLabs pick sentence boundaries, so the
  client never has to buffer for prosody.
- **One process per turn, not per assistant message** — the model resumes talking after tool
  calls, and a process per message overlaps. The child is respawned on demand because a long
  turn can outlive the websocket's 180s inactivity cap.
- **Markdown is stripped before speaking** (`Sanitizer`), statefully, because fenced code
  blocks span lines and are unlistenable; a fence becomes the words "code block".
- **`mpv --no-terminal` is mandatory** — `speak` runs inside TUIs and mpv otherwise grabs the
  terminal and corrupts the interface.
- **Thinking blocks are not read out**; the first one per turn plays a cached earcon instead,
  generated once into `~/.cache/speak/` since it never changes.
- The ElevenLabs MCP server and the `generate-speech` skill are unrelated to this — they exist
  for producing audio assets (demo videos), not for listening to responses.

## Cross-session agent messaging

Handled entirely by Herdr's socket API (`herdr agent list` / `herdr agent prompt`), documented
for agents in the `agent-messaging` skill. There is no custom bus, hook, or pi extension.

A hand-rolled bus (presence files, per-session inboxes, a Claude `Stop` hook, a pi inbox
watcher) was built first and then deleted — Herdr already did all of it, and did the one
thing the bus could not: **`herdr agent prompt` wakes an idle Claude session.** Claude Code
has no supported way to start a turn in an idle TUI session on its own. `Stop` only fires at
turn end, `initialUserMessage` only at session start, and `FileChanged` is side-effect-only
("exit code and output are ignored"), so it can detect an incoming message but not deliver it.

Verified behaviour, worth not re-deriving:

- Target **idle** → prompt starts a turn immediately. Target **working** → queued, delivered
  at end of turn. Target **not running** → nothing is queued, message lost.
- `herdr agent prompt --wait` reports `timeout` even on success when the turn finishes before
  Herdr observes the state change. Send without `--wait`; poll with `herdr agent wait`.
- `herdr pane current` self-identifies the calling pane, so no env plumbing is needed.

The trade-off accepted: this only works inside Herdr. Outside it, there is no messaging.

## Gotchas

- **`xps` full eval / `nix flake check` currently fails** on a pre-existing nixpkgs
  insecure-package gate (`nodejs-slim`), unrelated to most changes. `mbp` evaluates clean.
- **Verify tool config against the installed version, not memory** — e.g. lazygit moved
  `git.paging` → `git.pagers` (array); difftastic's HM module writes `programs.git.enable`,
  so gating `difftastic.enable` on `config.programs.git.enable` causes infinite recursion.
- **Firefox/gwfox needs `sidebar.visibility = "hide-sidebar"`.** gwfox styles the collapsed
  vertical-tabs sidebar — and the floating urlbar that `gwfox.urlbar` moves into it — only
  inside `@media -moz-pref("sidebar.visibility", "hide-sidebar")`. Under the default
  `always-show` the collapsed state has no rules at all: Firefox keeps reserving the launcher
  strip and cmd+L focuses an urlbar that is positioned nowhere.
- **Never patch gwfox's `userChrome.css`** — it is one deeply nested CSS-nesting tree, so a
  patch hunk's context lands wherever it happens to sit after an update; a previous
  collapsed-sidebar patch silently ended up nested inside the `hide-sidebar` media query and
  never applied. Overrides go in `gwfox-overrides.css`, appended by the `gwfoxUserChrome`
  derivation, so they are always top-level.
