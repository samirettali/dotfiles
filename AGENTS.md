# AGENTS.md

Nix flake dotfiles managing macOS with nix-darwin and NixOS with home-manager.
Hosts are `mbp` (darwin), `xps` (nixos), and `andromeda` (home-manager only).

This repository also carries `settali`, the work Mac, which company policy keeps
off nix: it is configured from `chezmoi/` with Homebrew, and it appears in no
flake output. See "The work Mac" below.

## Commands

- `make build` — rebuild the current host with nix-darwin or NixOS.
- `make fmt` — format all Nix files with `alejandra`. Run before committing.
- `make check` — run `nix flake check`.
- `make models` — refresh pinned OpenRouter provider limits, then run `make build`.
- `make update` — run `nix flake update`.

Evaluate one option without building:

```sh
nix eval '.#darwinConfigurations.mbp.config.home-manager.users.samir.<option>'
```

The `warning: Git tree ... is dirty` line during evaluation is benign.

## Conventions

- Use concise, lowercase Conventional Commit subjects: `type(scope): subject`.
- Add a commit body only when it explains a useful reason.
- Format every edited `.nix` file with `alejandra` before committing.
- New files are invisible to the flake until staged. Run `git add -N <file>` before evaluation.
- Always commit with an explicit pathspec because files may only be staged for flake evaluation.
- Avoid repeated full rebuilds while iterating. Test the tool directly, then move the settled change back into Nix.
- Build an instrument when measurement will settle a question faster than another guess.
- Never use `mkOutOfStoreSymlink` or non-store symlinks unless Samir agrees.
- Keep comments sparse.
- Keep this file limited to cross-cutting guidance. Put subsystem decisions in `docs/` and link them below.

## Structure

- `flake.nix` wires inputs and hosts through `mkHomeManagerConfig`.
- `inputs` reaches home-manager modules through `extraSpecialArgs`.
- `machines/<host>.nix` contains host and system configuration.
- `home/` contains user configuration.
- `home/packages/{shell,dev,desktop}/` use one file per tool, imported by each directory's `default.nix`.
- Host features pass through `mkHomeManagerConfig { features = ...; }` and default to `defaultFeatures`.
- `js` and `python` are `false`, `"minimal"`, or `"full"`; other features are booleans.
- Use the `nurPkgs` special argument instead of expanding `samirettali-nur.packages.${system}`.

## Repository ownership

`andromeda` is an Ubuntu ARM server where Nix owns only Samir's user profile.

| Layer | Owner | Contents |
| --- | --- | --- |
| System | `servers`, Ansible roles | OS packages, Docker, SSH, and anything requiring root |
| Services | `servers`, Compose and Ansible | Containers, mounted configuration, and rendered environment files |
| User profile | this repository, home-manager | Shell, Neovim, CLI tools, and agents |
| Home-manager bootstrap | `servers`, `home-manager` role | Nix installation, clone, build, and activation |

Use Ansible for anything requiring root or needed before Nix works.
Use this repository for files under `/home/samir`.

Store service secrets in the `servers` ansible-vault.
Store secrets consumed by Samir's tools in this repository with sops.

Use `infra` for account-wide resources on third-party systems.
Use each project's `infra/` directory for resources that share that project's lifecycle.

## The work Mac

`settali` cannot run nix, so Homebrew installs the tools from `chezmoi/dot_Brewfile`
and chezmoi copies the configuration from `chezmoi/`. A file that needs a value
from the machine ends in `.tmpl`.

An app of Samir's that runs on both machines is therefore configured twice:

- `mbp` gets the copy nix generates — `home/mac/sottomano.nix` writes
  `~/.config/sottomano/keymap.json` from a literal attribute set.
- `settali` gets `chezmoi/dot_config/<app>/`, kept in step by hand.

Two rules for the work copy:

- Name every command by absolute path: `/opt/homebrew/bin/jq`,
  `{{ .chezmoi.homeDir }}/go/bin/spotctl`. Store paths do not exist there, and an
  app launched by launchd has neither Homebrew nor `~/go/bin` on its PATH.
- Leave out whatever that machine has not got — the rbw vault, the sketchybar
  hooks — and keep anything company-specific out of this repository.

## Adding packages

- Prefer a home-manager `programs.<name>` or `services.<name>` module over `home.packages`.
- Add shell tools in `home/packages/shell/<name>.nix` and import them from `default.nix`.
- Keep the intentionally commented package entries in `home/packages/shell/default.nix`.

## Subsystem documentation

Read the matching document before changing that subsystem:

- `docs/ai/pi-models.md` — pi model registry, provider pinning, and limit synchronization.
- `docs/ai/spoken-responses.md` — streamed ElevenLabs responses from pi.
- `docs/herdr.md` — patched fork, builds, testing, and Neovim navigation.
- `docs/sketchybar.md` — pending agents and AI subscription usage.
- `docs/macos-tcc.md` — permissions, application signatures, and stable launch paths.
- `docs/helium.md` — the Chromium side: re-signing, Widevine, pinned extensions.

## Skills

- `home/packages/ai/coding-agent-skills.nix` is the shared skill registry for all agents.
- External skills are pinned as `flake = false` inputs and updated with `nix flake update`.
- Repository skills live in `.agents/skills/<name>/`.
- Claude Code reaches repository skills through `.claude/skills/<name>` symlinks.
- Follow `.agents/skills/add-skill` when adding a skill.

## MCP servers

Declare MCP servers once in `home/packages/ai/mcp.nix`.
Home-manager exposes them to Claude Code, Codex, and pi.
Treat vendor plugin instructions as an MCP declaration plus any required skills.
Do not install a Claude-only plugin when the shared configuration can represent it.

## Known gotchas

- `xps` full evaluation currently fails on the nixpkgs insecure-package gate for `nodejs-slim`.
- `mbp` evaluates cleanly.
- Verify tool configuration against the installed version rather than memory.
- Lazygit uses `git.pagers`, not the former `git.paging` option.
- Difftastic's home-manager module writes `programs.git.enable`; gating it on that option causes recursion.
