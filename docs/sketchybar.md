# Sketchybar integrations

Read this before changing the workspace, pending-agent, Claude usage, mail, gas, or market items.

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

`items/spotify.lua` listens to Spotify's `com.spotify.client.PlaybackStateChanged` distributed notification, which carries state, title, artist and track URI, so track changes need no polling.
Sketchybar's `media_change` never fires on macOS 26: MediaRemote now requires an Apple entitlement.
The item sets `updates=on` because the default, `when_shown`, drops events while it is hidden.
A JXA query covers startup, wake and unlock, when notifications may have been missed.
Keep the item hidden when Spotify has no track, and derive Sottotesto links from Spotify's track URI.

## Fastmail unread

`items/mail.lua` shows the unread count of the Fastmail inbox, hidden at zero.
Clicking it opens the inbox in the browser.

`mail-sketchybar` lives under `home/packages/shell/scripts/`.
A LaunchAgent in `home/mac/sketchybar.nix` holds Fastmail's JMAP event source, a Server-Sent Events stream, and triggers the `mail_unread` event.
Nothing polls.

- The token is the read-only JMAP API token `fastmail-api-key` in the rbw vault, with the Email scope only.
- Check `rbw unlocked` before `rbw get`: on a locked vault `rbw get` opens a pinentry prompt from a background process.
  While the vault is locked, the watcher retries every minute.
- Fastmail ignores ping intervals below 30 seconds.
  The watcher treats 75 seconds of silence as a dead connection, which is also how sleep shows up, and reconnects.
- Count with `Mailbox/get` on every `state` event.
  The first `state` arrives on connect, so a reconnect recounts what changed while the stream was down.

## Ethereum gas

`items/gas.lua` shows the Ethereum logo, in Ethereum's blue-violet, and the mainnet base fee in gwei.
Clicking it opens Etherscan's gas tracker.

`gas-sketchybar` lives under `home/packages/shell/scripts/`.
A LaunchAgent in `home/mac/sketchybar.nix` holds an `eth_subscribe newHeads` subscription on Infura's WebSocket and triggers the `gas_price` event.
Nothing polls.

- The key is `infura-api-key` in the rbw vault, read the same way as the Fastmail token, with the same wait while the vault is locked.
- Every block header carries `baseFeePerGas`, so the base fee costs no request beyond the subscription.
  The priority fee would cost an `eth_maxPriorityFeePerGas` call per block, and is left out.
- The watcher triggers on every block, not only on a change, so a restarted Sketchybar shows the fee again within one block.
  The fee is rounded to two significant digits below 1 gwei, one decimal below 10, whole numbers above, choosing the format from the rounded value.
- The item sits between the market prices and the Claude usage, behind its own separator, which hides with the item.
- A block is due every 12 seconds, so 60 seconds of silence counts as a dead connection and the watcher reconnects.
- While the subscription is down, the last fee turns grey. The first block after a reconnect restores it.
- The item also turns grey on `system_woke`: the watcher's timeouts run on a monotonic clock that stops during sleep, so a dead socket can take up to a minute after wake to notice.
- `publicnode` closed the subscription on a keepalive timeout when tested; `wss://eth.drpc.org` worked without a key.

## Market prices

`items/market.lua` shows a chart icon and two figures, crypto then stocks: the change of each side's total market cap.
The list lives in `home/mac/sketchybar.nix`, in popup order; `sketchybarrc` hands its JSON to the item as `MARKETS`, and the LaunchAgent passes the same file to the watcher.
Clicking the item opens a popup with every market under a Crypto, a Stocks and a Macro heading. Crypto and stocks are sorted by market cap, largest first; macro keeps the list's order.
The macro group holds indices, currencies and commodities from Yahoo; they have no market cap, so they get no figure in the bar.
A row reads name, price and change. A dot after the name shows the session in TradingView's colours: teal open, orange pre-market, light blue after-hours, purple overnight, grey closed.
A label carries one colour, so the dot is the row's background image, moved past the name by the image's `padding_left`; `home/mac/sketchybar-dots.py` draws one PNG per session at build time and `sketchybarrc` passes their directory as `MARKET_DOTS`.
Popup rows default to the bar's height, so the item sets `popup.height`; a popup cell grows to its item's background, so an invisible, taller background on a heading opens the space between groups.
Clicking a row opens the market on Binance or Yahoo Finance.
The two figures are two items, `market` and `market.stocks`, because one label carries one colour. The popup hangs from `market.stocks`, the right edge of the pair, as the Claude usage popup hangs from `usage.7d`; that item stays drawn while the crypto figure shows, because Sketchybar draws no popup for an item it does not draw.

`market-sketchybar` lives under `home/packages/shell/scripts/`.
A LaunchAgent in `home/mac/sketchybar.nix` holds two WebSockets, writes `~/.cache/sketchybar/market.json` and triggers `market_update`.
It triggers at most once a second, and only when a formatted value changed.
Nothing polls, and neither source needs a key.

- Crypto comes from Binance's `@ticker` streams, one update per second per pair, against USDT.
  The change is over the rolling 24 hours. Binance closes every connection after 24 hours; the watcher reconnects.
- Stocks come from Yahoo Finance's unofficial streamer, `wss://streamer.finance.yahoo.com/?version=2`: JSON carrying a base64 `PricingData` protobuf, decoded by hand.
  yfinance's `pricing.proto` names the fields. It is the only free stream found that covers small caps, pre-market and after-hours; Alpaca and Tiingo stream IEX only, Finnhub trades only, Twelve Data eight trial symbols.
- Yahoo sends a symbol only when it trades, so a price from before a reconnect may be hours old.
  Each Yahoo connection reads every stock the stream has not sent on it from `query1.finance.yahoo.com/v8/finance/chart`, replacing the old price, and retries failures every 60 seconds.
  It reads `fulldayPrice` and `fulldayChangePercent`, which include extended hours, falling back to `regularMarketPrice` against `chartPreviousClose`.
- The session comes from the same endpoint's `currentTradingPeriod`, read for every symbol every 30 minutes and shifted onto later weekdays between reads. Stocks and ETFs add the overnight session (20:00 to 4:00 ET, Sunday to Thursday) by the clock. Futures and currencies get a placeholder from 00:00 to 23:59, so they read open through the CME's daily break and closed on Sunday evening.
  The endpoint answers 429 without a browser User-Agent.
- The change is always measured from the previous close. After hours field 8 measures from the regular close instead, so the watcher prefers field 47, which is absent from yfinance's proto and was read off live messages.
- `market_hours` (field 7) is 1 for crypto, 2 after-hours and 4 overnight (20:00 to 4:00 ET). Yahoo counts the overnight session as the next trading day, so the change starts again from the regular close at 20:00 ET. Proto3 omits zero, so a missing field reads as pre-market; pre-market is unverified.
- A side's figure is the change of its total market cap, live price times units outstanding, against the same total at the previous close.
  Units come once a day from `v7/finance/quote`, crypto as `<coin>-USD`, and are cached in `~/.cache/sketchybar/market-units.json` across restarts.
  That endpoint wants the crumb of Yahoo's session: a cookie from `fc.yahoo.com`, which answers 404 and sets it anyway, then `v1/test/getcrumb`.
  Units are `marketCap` over `regularMarketPrice`, not `sharesOutstanding`, which counts one share class only: GOOG's leaves out GOOGL.
  A market without units drops out of its side's figure; with none at all the figure falls back to a plain average.
- Stocks go quiet when the market closes, so silence cannot tell a dead socket from a weekend. The Yahoo connection also subscribes `BTC-USD` as a heartbeat and does not show it.
  The subscription is re-sent every 15 seconds, as yfinance does.
- A source counts as down after 15 seconds of silence for Binance and 30 for Yahoo, measured on the wall clock. The wall clock runs through sleep, so prices turn grey on wake without the `system_woke` handling the gas item needs, and the watcher reconnects.

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

## Claude usage

`items/ai_usage.lua` shows the Claude mark (`:claude:` from sketchybar-app-font, in Claude's orange) followed by the 5-hour and 7-day percentages.
Each percentage turns yellow at 70% and red at 90%, and fractional usage rounds up.
The two percentages are two items, `usage` and `usage.7d`, because one label carries one colour.
The popup hangs from `usage.7d`, the right edge of the pair, so its right-aligned rows line up with the widget; clicking either item opens it.
Each row is a slider with the window, its reset instant and the percentage.
The reset instants sit right-aligned in a fixed field so the times stack in one column, and the weekday appears only beyond twenty hours.
Clicking a row opens claude.ai's usage page and closes the popup.

Claude Code's `statusLine` command (`home/packages/ai/claude-usage-statusline.py`) receives `rate_limits` on every render,
writes them to `~/.cache/sketchybar/claude-usage.json` when they change, and triggers `claude_usage`.
The item reads that file on `claude_usage`, at startup and on wake, so it shows what the last active Claude Code session saw.
The file is written atomically and survives restarts, so the item keeps no cache of its own.
The status line prints nothing.

The file changes only while a session runs.
A 60-second routine re-reads it and shows 0% for a window whose reset instant has passed.

Only the 5-hour and 7-day windows reach the status line:
Claude Code builds that payload from the `anthropic-ratelimit-unified-*` response headers,
which carry `five_hour`, `seven_day`, `seven_day_overage_included` and `overage` and nothing else.
Model-scoped weekly caps exist only in `api.anthropic.com/api/oauth/usage`; they were dropped, together with Codex and the `ai-usage` poller that fetched both.

## Spacing and separators

`separator.lua` adds a thin `|` between groups, and `items/init.lua` places one between the `require` calls.
The items that show only when something needs you (unread mail, pending agents, provider incidents) sit on the left after the front app, behind one separator from `alerts.lua`, and their popups open left-aligned.
Each reports its visibility with `alerts.show`, and the separator shows while any of them does.
Right-side items render in creation order, rightmost first, so the position follows from where the call sits.
Give the separator label an explicit width: Sketchybar sizes a label from the glyph's tight bounding box,
and the pipe's is two pixels wide, so without a width the character is clipped away entirely.

Every visible gap on the bar is 14 points, measured on ink rather than on item boxes.
Equal padding still looks unequal, because each glyph leaves a different amount of empty box around itself.
Balance a gap by trimming the padding of one neighbour, and check the result on a screenshot instead of guessing.
Digits stay one point apart even in a monospace font, which guarantees equal advance, not equal ink.

The same measure makes text move. Sketchybar sizes a label from its glyphs' ink (`kCTLineBoundsUseGlyphPathBounds` in `src/text.c`), so a ticking number changes its label's width and shifts every item beside it, and leading or trailing spaces add nothing.
Give such a label an explicit width from `mono.lua`, which counts characters at the font's 8.4-point advance: the clock, the market prices and the popup's columns all use it.

## SbarLua callbacks

Keep SbarLua hotloading disabled.
Sketchybar starts a new Lua event loop on every hotload without stopping the old one, so click callbacks accumulate and toggle popups repeatedly.
The Home Manager file hook restarts the LaunchAgent after configuration changes instead.

`sbar.exec` passes decoded JSON to its callback as a Lua table.
It passes plain command output as a string.
Handle both types.
Calling `cjson.decode` unconditionally raises silently inside the callback and leaves the item stale.
