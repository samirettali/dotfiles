## About me

- Samir Ettali, backend engineer in Turin, Italy.
- I work at a crypto exchange, Young Platform: backend, blockchain, fintech.
- I come from security, though I no longer do bug bounties or CTFs.
- I keep Neovim editing-first: native features and small plugins over IDE-like ones.
- I open issues on my own repos as to-dos, not only for defects, so Issues stay enabled everywhere.
- I reject a design that works but breaks the convention around it.
- I notice micro-asymmetries and inconsistent timings in a UI.

## What I know

Pitch explanations with this, not the work itself. Go as technical as you like on the first block. On the last, compare the unfamiliar thing to something I already know. Never turn a request to build something into a lesson about it.

Deep, and daily:

- Go: services, gRPC and protobuf
- .NET/C# with EF Core
- Kafka, Redis, MongoDB, SQL Server
- Nix, NixOS and nix-darwin

Enough to ship something whole:

- React and TypeScript
- EVM and account abstraction
- Python

Enough to change something that exists:

- Rust and Solidity
- Terraform
- Lambda, S3, KMS

Never written a line myself, only through agents:

- Swift and SwiftUI
- Ansible

## Tools I use daily

`mbp` is my own Mac (nix-darwin), where I do everything that is mine. `settali` is my work Mac, where company policy forbids nix. `andromeda` is my Linux server. `xps` is a NixOS laptop I barely use any more.

- sketchybar — the menu bar
- aerospace — tiling window manager
- Ghostty — terminal
- herdr — terminal multiplexer
- Neovim — editor
- fish — shell
- fzf — fuzzy finder
- zoxide — directory jumping
- ripgrep — search in files
- fd — find files
- lazygit — git
- lazydocker — docker
- gh — GitHub CLI
- direnv — per-project environments
- rbw — Bitwarden CLI
- spotctl — Spotify CLI
- linkding — bookmarks
- sops — secrets
- nix and home-manager — everything declared
- NUR — where I publish my own packages
- uv — Python

## Working with me

- Write files only through the editing tools, never with sed, awk, python or echo. A script that writes at the end loses every earlier edit when an assert fails halfway, and running it again duplicates what did land.
- Do what was asked and nothing more. Ask before doing anything else, unless I say you have a free hand.
- Ask until an unclear request is clear. Assume nothing.
- I dictate, so expect mangled words: read them by sound, and ask whenever a name or an identifier is at stake.
- Say what will not work before building it, not after.
- Work in a git worktree unless I say otherwise: I sit on main, and I do not want my checkout moved under me.
- Prefer the simplest solution that meets the requirement, and say so when something is over-engineered.
- Verify in seconds what you would otherwise assert: measure the latency, read the source, take a stack from the hung process, whatever settles it. A wrong theory costs more than the command that rules it out.

## Conventions

- Write everything that lands in a repository in English, whatever language we are speaking: issues, pull requests, commit messages, docs and code comments
- One commit per logical change, and only what this task changed
- Never pass `-c user.name` or `-c user.email` to git: the repository already knows who I am, and a name taken from the session context signs the commit as somebody else
- Title a pull request like a commit subject

## Memory

- Edit this file at `~/dev/dotfiles/home/packages/ai/agents.md`. The deployed copies (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.pi/agent/AGENTS.md`) are read-only store symlinks and land on the next switch.
- The "This machine" section is not in this file: it lives in `home/packages/ai/machines/<host>.md`. `agents.nix` appends it from `vars.hostname`, and chezmoi appends it from `.profile` on the work Mac.
- The "Projects" section is not in this file either: it lives in `home/packages/ai/projects.md`, and the work Mac does not get it.
- Never use a built-in memory tool. I run Claude Code, Codex and pi, and per-tool memories drift apart; `AGENTS.md` is the only store.
- Put durable facts in the relevant project's `AGENTS.md`. Anything long or rarely needed gets its own file, linked from there in one line.
