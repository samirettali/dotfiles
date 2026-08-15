# Hammerspoon pickers

Read this before changing a Hammerspoon picker or its shared framework.

## Shared framework

Three modules under `home/dotfiles/hammerspoon/` back every picker:

- `canvas.lua` draws the interface.
- `task.lua` exposes `task.run(path, args, done, onError)` and owns process spawning.
- `frecency.lua` exposes `frecency.new(settingsKey)`, `scores()`, and `remember(id)`.

`hs.chooser` was rejected because its native table and system font clash with the existing alerts.
`canvas.picker` matches the rounded box, font, and border from `hs.alert.defaultStyle`.
Only one modal exists at once; prompts and pickers share the canvas, key tap, and editing keys.

Nix renders consumers that need store paths in `home/mac/hammerspoon.nix`.
The current consumers are `.hammerspoon/rbw.lua`, `.hammerspoon/spotctl.lua`, and `.hammerspoon/bookmarks.lua`.
`recursive_binder.lua` loads them through `pcall(require, ...)`, so an absent rendered module is harmless.

## Framework invariants

- Give `hs.task` a stream callback for output that can exceed the pipe buffer.
  Without it, the child can block in `write()` before the completion callback drains the pipe.
  The final stream call can follow completion, so `task.lua` uses a deferred delivery handshake.
- Hold each `hs.task` in a module-level table.
  The userdata can be collected mid-flight when no reference survives.
- Compute vertical text placement explicitly.
  `hs.canvas` pins text to the top of its frame instead of centring it.
- Draw one `strokeAndFill` rectangle over the full canvas, matching `hs.alert`.
  The clipped outer half of the centred stroke is intentional.
- Wrap the key tap handler in `pcall` and tear down the modal on failure.
  The tap swallows all keys while active, so an unhandled error can lock the keyboard.
- Keep backspace UTF-8 aware by walking over continuation bytes.
- Keep fuzzy matching literal and local.
  Consecutive and early matches score higher, while name matches outrank subtext-only matches.
  Equal scores prefer shorter names before alphabetical order.
- Keep frecency in the caller.
  A choice carries a numeric `boost`; with an empty query, that boost defines ordering.
  Recent uses decay from ×4 within an hour to ×0.25 after a week.
  Cap the boost at 30 so it breaks close matches without outranking a clearly better result.
  `scores()` snapshots counts once per picker.
- Keep `onAlternate` on the highlighted row and bind it to shift+return.
  The binder cannot select a row-specific alternate action before the picker opens.
- Grow the box downward from a fixed top edge so narrowing the query never moves the list.

## Vault picker

The vault picker uses `rbw` from `home/packages/shell/rbw.nix`.
Its agent keeps the unlocked vault key in memory, which makes it suitable for a global hotkey.
The picker is bound to `cmd+space v`: `p` copies a password, `t` types it, `u` copies a username, and `o` copies an OTP.

- The generated rbw configuration is a read-only store symlink.
  Change `rbw.nix` instead of running `rbw config set`.
- rbw uses `pinentry-curses` because `pinentry-mac` crashes while registering with AppKit on macOS 26.
  Run `rbw unlock` once in a terminal after login; Hammerspoon can then use the in-memory key.
- rbw safely stores `device_id` in its data directory, not its configuration file.
- The home-manager module cannot set `sync_interval`.
  The picker reads the local database immediately and starts `rbw sync` in the background for the next invocation.
- `rbw list --raw` calls the type field `type`.
  Filter to `Login` and key choices by UUID so duplicate names remain unambiguous.
- Guard clipboard clearing with `hs.pasteboard.changeCount()`.
  Never clear a value that another application copied after the secret.
- Write secrets as `public.utf8-plain-text` and `org.nspasteboard.ConcealedType`.
  Clipboard managers such as Maccy then exclude them from history.
- Keep the type action's short delay.
  The picker key tap must stop before `keyStrokes` emits synthetic events.

## Playlist picker

The playlist picker is bound to `cmd+space m`.
It reads `spotctl playlist list` from the local SQLite cache and plays the selected playlist by ID.

- Never put a network freshness check on the read path.
  Open the picker from cached data, then run `spotctl playlist list --refresh` in the background.
- Spotify's response envelope uses `items`, not `playlists`.
- Every spotctl command returns JSON, including errors.
  Decode error objects instead of displaying raw JSON.

## Bookmark picker

The bookmark picker is bound to `cmd+space l`.
`bookmarks.lua` calls linkding through `hs.http` with `sops.secrets.linkding_api_token`.
It caches rows in `~/.cache/hammerspoon/bookmarks.json`.

Archived bookmarks are the curated collection here, not completed read-later items.
The active endpoint is the much larger read-later feed.
The picker therefore reads `/api/bookmarks/archived/` as a structural split rather than relying on tags.

- Never turn refresh into a `modified_since` delta.
  Archiving moves a bookmark between endpoints without producing a usable delta on either collection.
  Refetch the full archived collection so the cache cannot drift.
- Avoid decoding the large active collection on the picker path.
  Build rows once in `prime()` through `hs.timer.doAfter(0, ...)`, then only update frecency boosts per keypress.
- Linkding's `q=` syntax cannot express general negation.
  Archive state is an endpoint, and `?is_archived=true` is ignored.
- Bundles compose saved positive filters with either endpoint.
  They cannot express the negative collection split this picker needs.
