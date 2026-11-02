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
  carry no session link. `setup.sh` adds the tailnet's SessionStart hook to it
  ("The tailnet").
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
v=1.104.4
curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_${v}_amd64.tgz" | tar xz -C /opt
ln -sf /opt/tailscale_${v}_amd64/tailscale /opt/tailscale_${v}_amd64/tailscaled /usr/local/bin/
apt-get install -y openssh-client
```

The last four lines install Tailscale and the SSH client for the tailnet
(below).

The repository is public, so the clone needs no key; the script cannot read
the environment's variables and secrets anyway. A new session runs the script
as it is saved; a running one keeps what it started with.

On 2026-10-26 a probe confirmed that a session reads a `~/.claude/settings.json`
the setup script writes: its `env` reached the tool shell, a `permissions.deny`
entry removed the tool, and `attribution.commit` and `attribution.pr` set to ""
removed `Co-Authored-By` and the pull request's "Generated with" line, while
the session link stayed until `attribution.sessionUrl` is false.

## The tailnet

A cloud session joins the tailnet so that it can run commands on vega, where
the checkouts, caches and research-rpc proxies are, with `ssh vega`. Only cloud
sessions do: `setup.sh` adds the SessionStart hook `claude-cloud/tailscale.sh`
to the rendered settings and writes the `Host vega` entry of `~/.ssh/config`.
The hook starts `tailscaled` and runs `tailscale up` with `TS_AUTHKEY`, and
prints one line, which goes into the session's context: up, or why not. The
setup script cannot do it, since it cannot read the environment's variables.

- `TS_AUTHKEY`, an environment variable in the environment's settings, is a
  reusable, ephemeral, pre-approved auth key tagged `tag:claude-cloud`, so a
  container's node disappears with it. An auth key lasts 90 days at most. The
  hook reads it through `file:` and a process substitution, never as an
  argument.
- The tailnet's policy lets `tag:claude-cloud` reach only `tag:vega:22`, and
  its `ssh` rule accepts it there as `samir`, so the container holds no SSH
  key. vega runs Tailscale SSH (`tailscale set --ssh`); it takes port 22 on
  vega's Tailscale address only, and vega's own `sshd` stays on 38719.
- `tailscaled` runs with `--tun=userspace-networking`, and `ssh vega` goes
  through `tailscale nc`, so the container's routes and `/etc/resolv.conf`
  stay untouched. The container has no UDP to Tailscale (`netcheck` gave
  `UDP: false` on 2026-11-02): every packet goes through a DERP relay over
  the HTTPS proxy, Chicago at 33 ms from the container, so the link suits
  commands, not bulk transfers.
- A session with `ssh vega` runs anything there as `samir`, as a local
  session on vega does, so content the agent reads in the cloud (an issue, a
  web page) reaches vega's shell the same way.

## What the container lacks

Nix is installed, but the egress proxy refuses GitHub's tarballs, so no flake
of this repository evaluates there, and `get.chezmoi.io` is refused too. There
is no rbw vault, no pi, agy or Herdr, and no `gh`; of the tailnet, only vega.
`machines/claude-cloud.md` tells the agent so.
