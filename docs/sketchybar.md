# Sketchybar integrations

Read this before changing the workspace, pending-agent, or AI-usage items.

## AeroSpace workspaces

`items/aerospace.lua` discovers workspaces through AeroSpace's Unix socket.
Launchd does not guarantee that AeroSpace starts before Sketchybar.
Keep the hidden bootstrap item retrying once per second until discovery succeeds, then disable its timer.
Do not replace this with launch ordering or a fixed startup delay.

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

## Spotify now playing

`items/spotify.lua` listens to Sketchybar's `media_change` event, so track changes need no polling.
On each event it queries Spotify locally through JXA because MediaRemote omits the Spotify track ID.
The same query runs once at startup, while later events cover Spotify opening after Sketchybar.
Keep the item hidden when Spotify has no track, and derive Sottotesto links from Spotify's track URI.

## Compact system widgets

Battery and volume keep only their state icon in the bar.
Clicking either icon opens its popup.
The volume popup is a single slider: it reports the level and sets it where you click.
Sketchybar delivers a slider click in `PERCENTAGE`, not inside `INFO`, and reports nothing during a drag.
Subscribe the slider to `mouse.scrolled` as well, because the wheel is what gives continuous feedback.
The volume popup queries macOS separately so muting does not erase the configured percentage.
All popup items use `popup.lua`, which closes the previous popup before opening another.
Battery color stays neutral normally and turns yellow or red when low.
Charging needs no colour of its own: the glyph already carries the bolt.

GitHub, Anthropic, and OpenAI status items stay hidden while healthy and show only their severity-colored icon during an incident.
Clicking an incident icon opens the affected component names, colored by severity.
Clicking a component opens the corresponding provider status page.
Poll each provider every minute while healthy and every 15 seconds during an incident.

## AI subscription usage

`items/ai_usage.lua` keeps one usage icon visible and puts every Claude, Codex, Antigravity and Grok limit in its popup.
Each row is a Sketchybar slider: window on the left, filled bar, percentage on the right.
The icon, the bar and the percentage turn yellow at 70% and red at 90%.
Round fractional usage up and add popup rows as providers expose them.
Each provider has its own header, and only its `(cached)` suffix turns grey after that provider fails to refresh.
`ai-usage` under `home/packages/shell/scripts/` prints the providers as JSON.

Rows carry the reset instant, right-aligned in a fixed field so the times stack in one column.
The weekday appears only beyond twenty hours, which keeps the short windows narrow.
Clicking a row or a header opens that provider's usage page, taken from the `url` the script returns.

Poll each credential source every five minutes below its own threshold and every minute above it.
Opening the popup refreshes every source immediately.

Claude arrives in two pieces, because no single source carries both.

The plan's own windows cost nothing. Claude Code's `statusLine` command
(`home/packages/ai/claude-usage-statusline.py`) receives `rate_limits` on every render,
writes them to `~/.cache/sketchybar/claude-usage.json` when they change, and triggers `claude_usage`.
The `ai-usage claude` poller reads that file, so the widget shows what the last active
Claude Code session saw. The status line prints nothing.

Only the 5-hour and 7-day windows reach the status line, and no amount of work will change that:
Claude Code builds that payload from the `anthropic-ratelimit-unified-*` response headers,
which carry `five_hour`, `seven_day`, `seven_day_overage_included` and `overage` and nothing else.
A model-scoped weekly cap ("Fable", say) exists only in `api.anthropic.com/api/oauth/usage`.

That endpoint allows roughly one call an hour per access token and Claude Code spends them itself,
so a 429 there is the normal answer rather than a fault, and its `Retry-After` runs to most of an hour.
The model-scoped sections therefore work on a budget of their own:

- Start from `cachedUsageUtilization` in `~/.claude.json`, which is Claude Code's own copy of that
  endpoint's last answer, `limits[]` included. Free, but only rewritten when something made it ask.
- Ask the endpoint when that reading is over five minutes old and no `Retry-After` is still running.
  The refusal costs one request an hour; `~/.cache/sketchybar/claude-scoped.json` carries the reading
  and the block across runs.
- Past ninety minutes without a reading, return the sections with an `error` and no windows.
  The rows keep their last numbers and turn grey rather than disappearing.

Never refresh the token: Claude Code owns it, and writing a new one back to the keychain would race with it.

A poller can therefore fail on one section and succeed on another.
Mark only the section the error names; grey out all of a poller's sections only when nothing came back at all.

One poller may own several providers.
A poller's extra buckets become their own sections, keyed `<poller>.<group>` and named after the group,
because their percentage is not overall plan usage and reading it as such is wrong.
Sections, names and URLs come from the data and are cached, so a new group needs no code change.
A fetch that returns nothing at all marks every provider of that poller as cached and empties nothing.

No provider exposes a public usage API.
The script borrows credentials owned by the corresponding CLI:

- Codex stores its token in `~/.codex/auth.json`.
  Fetch `chatgpt.com/backend-api/wham/usage`.
- Antigravity stores its Google OAuth token in the login keychain under service `gemini`, account `antigravity`,
  as go-keyring base64 JSON with an `expiry`.
  Post `{}` to `daily-cloudcode-pa.googleapis.com/v1internal:retrieveUserQuotaSummary`
  with a `User-Agent` that names Antigravity, or the API answers `SUBSCRIPTION_REQUIRED`.
  That daily host is the one the CLI uses; `cloudcode-pa.googleapis.com` keeps a separate pool with other reset times.
  Gemini models and the Claude and GPT models are metered apart, so each group is its own section keyed `agy.<group>`.
  The percentage shown is `1 - remainingFraction`, and the weekly bucket is reordered after the 5-hour one.

The Antigravity token lives about an hour and only the CLI refreshes it.
When it has expired, or the request comes back 401 or 403, fall back to `agy --log-file /dev/null -p /usage --output-format json`,
which refreshes the keychain and returns the same groups in snake_case in about four seconds.
Keep `--log-file /dev/null`: every print-mode run otherwise opens a new log file under `~/.gemini/antigravity-cli/log`.

Grok keeps its OIDC token in `~/.grok/auth.json`, one entry per issuer with the JWT under `key` and an `expires_at`.
Fetch `cli-chat-proxy.grok.com/v1/billing?format=credits`, the call behind the TUI's `/usage`.
It returns the plan's billing period and `creditUsagePercent`, which the proxy omits while it is zero.
`grok.com/rest/rate-limits` refuses that token, and the proxy answers a bare completion request with 426, so this is the only read.

The Grok token lives a few hours and only the CLI refreshes it.
When it has expired, or the request comes back 401 or 403, fall back to `grok agent --no-leader stdio`:
send an Agent Client Protocol `initialize`, then the extension method `_x.ai/billing` with no session.
The underscore prefix is how ACP names extension methods; without it the agent answers "Method not found".
The agent refreshes the token, answers in half a second and leaves no session or log behind.

Label windows by duration (`5h`, `1d`, or `7d`), not from primary or secondary position.
The number and order of returned windows can change.

Codex tokens expire quickly.
When the direct request fails, fall back to `codex app-server` and call `account/rateLimits/read`.
The app server refreshes the token and returns equivalent data.
Read its long-lived stdout with a real deadline and always reap the process.
A stale token can produce Cloudflare 403 HTML rather than a JSON 401.

Discover app-server methods with `codex app-server generate-json-schema --out <dir>`.
The server keeps its connection open and interleaves notifications.
Read until the response with the requested ID arrives instead of waiting for EOF.

Cache each provider's last successful limits and update time across Sketchybar restarts.
A failed fetch must keep those values and mark that provider's header as cached so a temporary renewal or rate limit never empties the popup or looks fresh.

Keep one invisible poller per provider, because their rate limits are independent.

## Spacing and separators

`separator.lua` adds a thin `|` between groups, and `items/init.lua` places one between the `require` calls.
Right-side items render in creation order, rightmost first, so the position follows from where the call sits.
Give the separator label an explicit width: Sketchybar sizes a label from the glyph's tight bounding box,
and the pipe's is two pixels wide, so without a width the character is clipped away entirely.

Every visible gap on the bar is 14 points, measured on ink rather than on item boxes.
Equal padding still looks unequal, because each glyph leaves a different amount of empty box around itself.
Balance a gap by trimming the padding of one neighbour, and check the result on a screenshot instead of guessing.
Digits stay one point apart even in a monospace font, which guarantees equal advance, not equal ink.

## SbarLua callbacks

Keep SbarLua hotloading disabled.
Sketchybar starts a new Lua event loop on every hotload without stopping the old one, so click callbacks accumulate and toggle popups repeatedly.
The Home Manager file hook restarts the LaunchAgent after configuration changes instead.

`sbar.exec` passes decoded JSON to its callback as a Lua table.
It passes plain command output as a string.
Handle both types.
Calling `cjson.decode` unconditionally raises silently inside the callback and leaves the item stale.
