You are in a Claude Code cloud session (claude.ai/code): a Linux container
made for the session, with its repositories cloned fresh, and reclaimed after
a while idle. `claude-cloud/setup.sh` in `~/dev/dotfiles` installed this file,
the settings and the skills; the clone it ran from is gone.

- Anything worth keeping is committed and pushed before you stop: nothing
  else outlives the container.
- Nix is installed but cannot build my flakes: the egress proxy refuses
  GitHub's tarballs, so a flake with `github:` inputs fails to fetch.
- There is no rbw vault. Keys come from the environment's variables and
  secrets, set in its settings, under the names each project's `.envrc`
  uses. Never ask me to paste one into the chat. Firecrawl, the
  `generate-*` wrappers and `x-search` are not here: use WebSearch and
  WebFetch.
- `andromeda`, `orion` and the tailnet are out of reach, and with them their
  caches, proxies and nodes. Work that needs them (a backtest, a fork test, a
  measurement, a deploy) runs there: say so, and do the part that does not.
- The container is the isolation: work in the clone, with no worktree. My
  branch names hold here too: name the branch `issue-<N>-<slug>` or
  `<type>-<slug>` and push that, not the one the session names.
- GitHub goes through the session's GitHub tools; `gh` is not installed.
- pi, agy and Herdr are not here: a review a project asks of GPT or Gemini
  cannot run, so say so and run Opus's; subagents go through the native
  Agent tool.
