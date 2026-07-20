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
- When committing, prefers one commit per logical change.
- When asked to commit, commit only changes made by the current agent/task; leave
  all unrelated pre-existing changes unstaged and uncommitted.
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

## Projects

Projects live under `~/dev`, each with its own `AGENTS.md`. Read that file before
working on, or answering questions about, the project. When a change introduces a
non-obvious decision or context that wouldn't be clear from the code alone, update
that project's `AGENTS.md` to capture it.

- **dotfiles** — `~/dev/dotfiles` (this repo). NixOS + home-manager config.
- **selfhosted** — `~/dev/selfhosted`. Self-hosted stack (Docker Compose + Ansible), deployed on the `andromeda` host.
- **nur** — `~/dev/nur`. Personal NUR repository (samirettali/nur); dotfiles consumes it via the `nurPkgs` specialArg.

## Memory

- This very file lives in the dotfiles repo: to update these memories, edit
  `~/dev/dotfiles/home/packages/ai/agents-memory.md` (host-specific extras come
  from `config.dotfiles.agentsMemory.extra`). The deployed copies
  (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.pi/agent/AGENTS.md`) are
  read-only home-manager symlinks into the nix store; changes land on the next
  home-manager switch.
- Never use a built-in "memory" tool or feature. I use multiple agents (Claude
  Code, Codex, pi) and per-tool memories aren't shared — they drift and get lost.
  `AGENTS.md` is the single source of persistent project knowledge.
- Put durable facts and decisions in the relevant project's `AGENTS.md`.
- If something is long or only occasionally relevant, put it in a separate file
  and link it from `AGENTS.md` with a one-line description — so it's discoverable
  without bloating always-loaded context.
