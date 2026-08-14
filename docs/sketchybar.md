# Sketchybar integrations

Read this before changing the pending-agent or AI-usage items.

## Pending Herdr agents

`items/herdr.lua` shows agents waiting for input.
It counts `blocked` and `done`, never `working` or `idle`.
Its popup contains one clickable row per agent.

`herdr-sketchybar` lives under `home/packages/shell/scripts/`.
A LaunchAgent in `home/mac/sketchybar.nix` keeps Herdr's socket open and triggers the `herdr_agents` event.
Nothing polls.

- `pane.agent_status_changed` requires a `pane_id`; no global variant exists.
  Subscribe once per agent pane plus the parameterless lifecycle events.
  Reconnect whenever the set of agent panes changes.
  Do not replace this with noisy `pane.updated` subscriptions.
- Run `herdr agent list` on every event.
  An event describes one pane, not the current totals, so accumulating payloads would drift after a missed message.
- Write row details to `~/.cache/sketchybar/herdr-agents.json` before triggering the item.
  Pane IDs and titles need no custom encoding, and rows cannot disagree with the count.
- Focus rows with `herdr agent focus <pane_id>`.
  `herdr pane focus` accepts a direction, not an ID.
  Also run `open -a Ghostty` because Herdr focus is invisible behind another application.
- Give the LaunchAgent an explicit store-backed `PATH` for Herdr and Sketchybar.
  LaunchAgents inherit little environment, and `useUserPackages` installs binaries under
  `/etc/profiles/per-user/$USER/bin`.
- Log every watcher failure because click scripts and background agents otherwise fail silently.

## AI subscription usage

`items/ai_usage.lua` shows Claude and Codex plan usage.
It stays hidden below 70% and turns red at 90%.
`ai-usage` under `home/packages/shell/scripts/` prints both providers as JSON.

Poll every five minutes below the threshold and every minute above it.
The exact percentage only matters while the item is visible.
Clicking opens the provider's usage page.

Neither provider exposes a public usage API.
The script borrows credentials owned by the corresponding CLI:

- Claude Code stores its OAuth token in the login keychain under `Claude Code-credentials`.
  Fetch `api.anthropic.com/api/oauth/usage` with `anthropic-beta: oauth-2025-04-20`.
- Codex stores its token in `~/.codex/auth.json`.
  Fetch `chatgpt.com/backend-api/wham/usage`.

Label Codex windows from `limit_window_seconds`, not from primary or secondary position.
The number and order of returned windows can change.

Codex tokens expire quickly.
When the direct request fails, fall back to `codex app-server` and call `account/rateLimits/read`.
The app server refreshes the token and returns equivalent data.
A stale token can produce Cloudflare 403 HTML rather than a JSON 401.

Discover app-server methods with `codex app-server generate-json-schema --out <dir>`.
The server keeps its connection open and interleaves notifications.
Read until the response with the requested ID arrives instead of waiting for EOF.

Do not refresh or rewrite Claude's token.
Claude Code owns it, and another writer would race with the CLI.
Leave the existing item unchanged after a failed fetch so a temporary renewal never looks like reduced usage.

Keep the timer on the invisible `usage.poller` item.
One command serves both providers; attaching it to visible items would duplicate polling.

## SbarLua callbacks

`sbar.exec` passes decoded JSON to its callback as a Lua table.
It passes plain command output as a string.
Handle both types.
Calling `cjson.decode` unconditionally raises silently inside the callback and leaves the item stale.
