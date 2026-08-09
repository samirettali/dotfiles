# MEMORY

Curated, always-on facts about the user

## About me

- Samir Ettali — backend engineer, based in Turin, Italy.
- Works at a crypto exchange (Young Platform); backend + blockchain/fintech.
- Primary languages: Go (production backend) and .NET/C#; also Rust and Solidity/web3.
- Security background; active bug-bounty / CTF practice.
- Dev-tools obsessive: NixOS + nix-darwin, Neovim, keyboard-driven ("Mouseless").
  Publishes his own tools via NUR (samirettali/nur).
- Uses AI tools primarily in the terminal; in Neovim, prefers only lightweight inline-edit helpers, not full AI assistants.
- Prefers Neovim to stay editing-first/minimal, using native features and small focused plugins over big IDE-like plugins.
- Opens GitHub issues on his own repos as to-dos, not only for defects, which is
  why Issues stay enabled everywhere.
- When committing, prefers one commit per logical change.
- When asked to commit, commit only changes made by the current agent/task; leave
  all unrelated pre-existing changes unstaged and uncommitted.
- Pull request titles follow Conventional Commits too, exactly like commit
  subjects: `<type>(<scope>): <summary>`, imperative, no trailing period.
- Many of the tools he uses are his own (spotctl, sottovoce, pulse, the herdr
  fork, the NUR packages). When one of them is the limitation, changing the tool
  is as legitimate an option as working around it — often the one he prefers.
- Conceptual consistency weighs as much as visual consistency: he will reject a
  design that works if it diverges from the convention around it — a JSON
  envelope shaped differently from the API it mirrors, or a keyboard shortcut
  whose letter is arbitrary instead of a mnemonic for what it opens.
- Asks why before accepting a change. The reasoning is part of the deliverable
  rather than an extra: prefer a short, concrete justification to a change
  presented as self-evident.
- Sharp eye for visual detail: immediately notices micro-asymmetries, misalignments,
  spacing imbalances, and inconsistent animation/transition timings. In UI work,
  sweat these details proactively (consistent motion durations, symmetric edges,
  aligned rhythms) — he will spot them anyway.

## Interaction

- Address me as Samir in conversation.
- Don't take initiative beyond what we've agreed: do exactly what was asked and
  nothing more. If something else seems worth doing, ask first before doing it —
  unless I explicitly say you can do whatever you want, in which case go ahead.
- If a request is unclear or ambiguous, ask questions until it's clear. Don't
  assume or take anything for granted.
- Modify and write files only through the editing tools, never with
  python/perl/sed/awk/echo or other shell text-munging.
- Surface non-obvious problems, gotchas, or "this won't work" early — before
  building, not after.
- Prefer the simplest solution that meets the requirement; if something is
  over-engineered, say so.

## Web search

Two surfaces: the agent's built-in web search, and Exa (`web_search_exa` /
`web_fetch_exa`, from the `exa` MCP server; in pi they sit behind the generic
`mcp` tool).

- Default to the built-in search. It is cheaper in context by an order of
  magnitude (3-5 KB vs 60 KB) and it wins whenever the query has an exact
  keyword: an issue number, a version, a setting name, release notes.
- Reach for Exa when the query is a description rather than keywords ("the post
  where an engineer explains why they went back to a monolith"), when the
  primary source matters more than commentary about it, or for recent security
  writeups and CVEs. Measured on an 8-query benchmark, that is where the gap is
  real; elsewhere the two tie.
- Ask Exa for ~5 results unless more are needed; cost in context scales with
  `numResults`, and each result carries long highlight extracts.

## Projects

Projects live under `~/dev`, each with its own `AGENTS.md`. Read that file before
working on, or answering questions about, the project. When a change introduces a
non-obvious decision or context that wouldn't be clear from the code alone, update
that project's `AGENTS.md` to capture it.

- **dotfiles** — `~/dev/dotfiles` (this repo). NixOS + home-manager config.
- **selfhosted** — `~/dev/selfhosted`. Self-hosted stack (Docker Compose + Ansible), deployed on the `andromeda` host.
- **nur** — `~/dev/nur`. Personal NUR repository (samirettali/nur); dotfiles consumes it via the `nurPkgs` specialArg.
- **sottocasa** — `~/dev/sottocasa`. Multi-tenant booking product (Go API + React
  owner panel). Dev runs on `andromeda` (air + pnpm dev), served tailnet-only at
  https://sottocasa-dev.samirettali.com via the side-projects proxy. ZITADEL
  identity managed by OpenTofu under infra/.
- **side-projects** — `~/dev/side-projects`. Small personal projects plus the
  shared tailnet-only Caddy that fronts host-run dev servers at
  *.samirettali.com. Deployed by the selfhosted Ansible playbook.
- **sottovoce** — `~/dev/sottovoce`. macOS menu bar dictation app (SwiftPM, no
  Xcode project). Distributed as a signed, notarised DMG built locally with
  `make release`; a Homebrew cask in samirettali/homebrew-tap is bumped by CI.
- **pulse** — `~/dev/pulse`. macOS menu bar app for live prices (Binance,
  Hyperliquid, Yahoo) and timezone clocks. Same build and release setup as
  sottovoce.
- **infra** — `~/dev/infra`. OpenTofu for the accounts rather than for a
  project: GitHub repository settings, Actions secrets, and the R2 bucket the
  states live in. Per-project infrastructure stays with its project.
- **spotctl** — `~/dev/spotctl`. Agent-friendly Spotify CLI in Go, shipped
  through NUR and consumed by the `spotify` skill (whose SKILL.md lives in the
  repo) and by the Hammerspoon playlist picker. Released by bumping `version`
  in `main.go` in a `chore: release vX.Y.Z` commit, then a signed annotated tag.

Both macOS apps sign with `Developer ID Application: Samir Ettali (22K9H4B864)`
and use `com.samirettali.<app>` bundle ids. Signing keys and notarisation
credentials never go to CI — releases are built on the laptop.

## Memory

- This very file lives in the dotfiles repo: to update these memories, edit
  `~/dev/dotfiles/home/packages/ai/agents.md`. It is identical on every host. The
  deployed copies (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
  `~/.pi/agent/AGENTS.md`) are read-only home-manager symlinks into the nix
  store; changes land on the next home-manager switch.
- Never use a built-in "memory" tool or feature. I use multiple agents (Claude
  Code, Codex, pi) and per-tool memories aren't shared — they drift and get lost.
  `AGENTS.md` is the single source of persistent project knowledge.
- Put durable facts and decisions in the relevant project's `AGENTS.md`.
- If something is long or only occasionally relevant, put it in a separate file
  and link it from `AGENTS.md` with a one-line description — so it's discoverable
  without bloating always-loaded context.
