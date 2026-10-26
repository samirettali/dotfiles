# Claude Code's cloud sessions

A cloud session (claude.ai/code) runs in a Linux container made for it, with
none of what home-manager installs: no `~/.claude/CLAUDE.md`, no settings, no
skills. The environment's setup script, which runs as the container starts and
before Claude Code, installs them from this repository.

## What a session gets

- `~/.claude/CLAUDE.md`: `agents.md`, `personal.md` and `projects.md`, with
  `machines/claude-cloud.md` as "This machine", put together by
  `claude-cloud/setup.sh` in the order `agents.nix` uses. It is not rendered,
  so an edit to those files reaches the next session once pushed.
- `~/.claude/settings.json`: mbp's, rendered by `make claude-cloud`, without
  the status line and the hooks (scripts nix builds for mbp), without
  `disableClaudeAiConnectors` (the session's GitHub tools may come through
  them), with WebSearch and WebFetch allowed (Firecrawl needs the rbw vault),
  and with `attribution.sessionUrl` false, so that commits and pull requests
  carry no session link.
- The skills that need neither rbw, nix nor Herdr: `commit`,
  `review-comments` and `review-loop`, rendered by `make claude-cloud`.

The render, like `make chezmoi`, builds mbp's Home Manager file tree and
copies from it: run it on `mbp`, review the diff, and commit
`claude-cloud/home/`. `make check-claude-cloud` fails on a render left
behind. The render writes finished files with no template, since the
container has no value of its own to fill in and no chezmoi.

## The environment's setup script

In the cloud environment's settings (the environment menu in a session's title
bar, then Edit), under Setup script:

```bash
#!/bin/bash
set -euo pipefail
git clone --depth 1 https://github.com/samirettali/dotfiles /tmp/dotfiles
bash /tmp/dotfiles/claude-cloud/setup.sh
rm -rf /tmp/dotfiles
```

The repository is public, so the clone needs no key; the script cannot read
the environment's variables and secrets anyway. A new session runs the script
as it is saved; a running one keeps what it started with.

On 2026-10-26 a probe confirmed that a session reads a `~/.claude/settings.json`
the setup script writes: its `env` reached the tool shell, a `permissions.deny`
entry removed the tool, and `attribution.commit` and `attribution.pr` set to ""
removed `Co-Authored-By` and the pull request's "Generated with" line, while
the session link stayed until `attribution.sessionUrl` is false.

## What the container lacks

Nix is installed, but the egress proxy refuses GitHub's tarballs, so no flake
of this repository evaluates there, and `get.chezmoi.io` is refused too. There
is no rbw vault, no tailnet, no pi, agy or Herdr, and no `gh`.
`machines/claude-cloud.md` tells the agent so.
