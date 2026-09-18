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
- fluxctl — Miniflux CLI, my RSS reader
- linkctl — linkding CLI, my bookmarks
- sops — secrets
- nix and home-manager — everything declared
- NUR — where I publish my own packages
- uv — Python
- agy (Antigravity CLI) — work outside the code: LinkedIn links, notes from podcasts and YouTube tech talks into the Obsidian vault, throwaway scripts that are not meant to stay. On trial: whether it writes code well is still an open question.

## Working with me

- Do what was asked and nothing more. Ask before doing anything else, unless I say you have a free hand.
- Investigate facts directly. Ask when unresolved ambiguity would change scope, correctness, external effects, or an established preference; use judgment for routine, reversible choices within the task.
- I dictate, so expect mangled words: read them by sound, and ask whenever a name or an identifier is at stake.
- Say what will not work before building it, not after.
- Work in a git worktree unless I say otherwise: I sit on main, and I do not want my checkout moved under me.
- Prefer the simplest solution that meets the requirement, and say so when something is over-engineered.
- Verify in seconds what you would otherwise assert: measure the latency, read the source, take a stack from the hung process, whatever settles it. A wrong theory costs more than the command that rules it out.
- On `andromeda`, dev servers bind to `0.0.0.0`, including through `make dev`, so I reach them at `http://andromeda:<port>` from my Mac without forwarding ports. Binding is not enough for Vite: it rejects unknown Host headers, so `server.allowedHosts` must always include `andromeda` in dev.
- Never kill a process by name (`pkill -f vite`, `killall node`): other sessions run processes with the same name on this host, and `pkill -f` matches the shell running it too. Find the specific PID first (`ss -ltnp` for the port, `pgrep -af` to read the list) and kill that one PID; if you did not start it and it is not yours to stop, leave it alone.
- My CLI wrappers (`firecrawl`, `generate-*`, `tavily`, `x-search`) take their keys from the environment or the rbw vault. Never print, store or pass a key as an argument. If the vault is locked, ask me to unlock it; do not set up another credential store, run a login or installer, or fall back to keyless access.

## How to write

This applies to everything you write, in the terminal as much as in a repository: replies, commit bodies, pull requests, tickets, docs, code comments. When we speak Italian the same rules hold; the wording below is about English because that is what lands in a repository.

- The readers know English well but are not native speakers: a metaphor or an idiom costs them a translation, the plain word does not.
- One idea per sentence, the subject first, active voice. "RejectIfDeleting checks the caller", not "the caller is what the gate is evaluated against".
- Say the concrete thing, not a metaphor for it. "The token is not in the transfers array", not "the token is not carried by the leg". If a sentence needs a picture to be understood, it is describing the thing from too far away.
- No noun stacks: a chain of nouns the reader has to unpack from the end. "The fee, in that token, in the worst case", not "the worst case network fee token amount". Split it with a preposition or a clause.
- Name the thing as the code names it. `RejectIfDeleting`, not "the deletion middleware": I copy the name and search for it. The same thing keeps the same name in every mention.
- Say only what the reader cannot see for themselves. Do not restate the request, the diff, or the ticket.
- Do not narrate the alternative not taken, a defence against a future reader, or how you got here, unless I ask. In a repository those go in the pull request, not in a comment.

## Conventions

- Write everything that lands in a repository in English, whatever language we are speaking: issues, pull requests, commit messages, docs and code comments
- One commit per logical change, and only what this task changed
- Never pass `-c user.name` or `-c user.email` to git: the repository already knows who I am, and a name taken from the session context signs the commit as somebody else
- Title a pull request like a commit subject

## Memory

- Edit this file at `~/dev/dotfiles/home/packages/ai/agents.md`. The deployed copies (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.pi/agent/AGENTS.md`) are read-only store symlinks and land on the next switch.
- The "This machine" section is not in this file: it lives in `home/packages/ai/machines/<host>.md`. `agents.nix` appends it from `vars.hostname`, and chezmoi appends it from `.profile` on the work Mac.
- The "Projects" section is not in this file either: it lives in `home/packages/ai/projects.md`, and the work Mac does not get it.
- Never use a built-in memory tool. I run Claude Code, Codex, pi and agy, and per-tool memories drift apart; `AGENTS.md` is the only store.
- Put durable facts in the relevant project's `AGENTS.md`. Anything long or rarely needed gets its own file, linked from there in one line.
