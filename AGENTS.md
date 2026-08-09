# AGENTS.md

Nix (flake) dotfiles managing macOS (nix-darwin) and NixOS via home-manager.
Hosts: `mbp` (darwin), `xps` (nixos), `andromeda` (server, home-manager only).

## Commands

- `make build` — rebuild current host (`nh darwin switch .` on macOS, `nixos-rebuild` on NixOS).
- `make fmt` — format all nix with `alejandra`. Run before committing.
- `make check` — `nix flake check`.
- `make models` — refresh the pinned OpenRouter provider limits in
  `home/packages/ai/pi-coding-agent/models.json` (see below); writes the file, then `make build`.
- `make update` — `nix flake update`.

Eval a single option without building:
```
nix eval '.#darwinConfigurations.mbp.config.home-manager.users.samir.<option>'
```
The `warning: Git tree ... is dirty` line during eval is benign.

## Conventions

- **Commits:** Conventional Commits, lowercase short subject; add a longer body only
  when it adds useful context, otherwise subject alone.
  `type(scope): subject` — types seen: `feat`, `fix`, `chore`, `refactor`.
- **Format edited `.nix` files with `alejandra` before committing** (`make fmt`).
- **New files are invisible to the flake until staged** (flake reads the git tree).
  Run `git add -N <file>` before `nix eval`/`flake lock`, or eval fails to find it.
  For the same reason, **always commit with an explicit pathspec**
  (`git commit -m … -- <paths>`): files are often staged only so the flake can see
  them, and a bare `git commit` carries them along.
- **Iterating through the flake is slow — get out of it while iterating.** A rebuild
  plus an app restart per attempt is fine once, punishing on the fourth. After a few
  rounds on the same thing, stop paying it: take that tool's config out of nix
  temporarily, write it straight to the path it belongs at, iterate there, and move
  the settled version back into the flake. Same idea one level up — when the answer
  needs measuring rather than guessing, build the instrument instead of trying again:
  the `firefox` skill exists because reading gwfox's CSS could not answer which rule
  was winning, and a debugging client could.
- **Never use `mkOutOfStoreSymlink` or symlinks to non-store paths** unless Samir agrees —
  use standard in-store `home.file` / module options.
- Keep comments sparse; the user dislikes noise.

## Structure

- `flake.nix` — inputs + per-host wiring via `mkHomeManagerConfig`. `inputs` is
  threaded into home-manager modules through `extraSpecialArgs`.
- `machines/<host>.nix` — host/system config.
- `home/` — user config. `home/packages/{shell,dev,desktop}/` use **one file per tool**,
  imported from each dir's `default.nix`.
- **Features** (`rust`, `go`, `js`, `python`, …) are passed per-host via
  `mkHomeManagerConfig { features = ...; }`, defaulting to `defaultFeatures` in `flake.nix`.
  `js`/`python` are tri-state strings (`false` | `"minimal"` | `"full"`), the rest are bools.
- **NUR packages:** use the `nurPkgs` specialArg (`nurPkgs.<pkg>`), not the long
  `samirettali-nur.packages.${system}` expression.

## andromeda: this repo vs `selfhosted`

`andromeda` is the only host where nix does **not** own the machine: it's an
Ubuntu ARM server, so this repo owns only the user profile
(`homeConfigurations.andromeda`, no `machines/` entry) while `~/dev/selfhosted`
owns the machine and the services through Ansible and Compose.

| Layer | Owner | What |
| --- | --- | --- |
| System | selfhosted, roles `common` + `docker` | OS packages, Docker, ssh — anything needing root |
| Services | selfhosted, `docker-compose.yml` + role `selfhosted` | containers, mounted configs, rendered env files |
| User profile | **this repo**, home-manager | shell, neovim, CLI tools, agents |
| The bridge | selfhosted, role `home-manager` | installs nix, clones this repo, runs `nix build …#homeConfigurations.andromeda.activationPackage` and activates it |

**The rule: does it need root? Ansible. Does it live in `/home/samir`? here.**
Anything that has to exist *before* nix works is necessarily Ansible.

**Secrets follow the same split.** A secret consumed by a service goes in
selfhosted's ansible-vault, because it ends up in an env file Docker reads as
root. A secret consumed by a tool *of yours* goes in sops here (`secrets/`,
age key at `~/.config/sops/age/keys.txt`), because it has to reach your profile
on every host — the OpenTofu state passphrases are the example.

## Adding packages

- If a package has a home-manager `programs.<name>` / `services.<name>` module, **prefer the
  module** over a raw `home.packages` entry — new file in `home/packages/shell/<name>.nix`,
  add it to the dir's `default.nix` imports.
- The user keeps unused packages commented in `home/packages/shell/default.nix` on purpose
  (as a "these exist" memo) — don't delete those comments.

## Skills (Claude Code / Codex / pi)

- Shared skill set lives in `home/packages/ai/coding-agent-skills.nix` (one source of
  truth: `{ name = dir-with-SKILL.md; }`); each agent materializes it into its own path.
- External skills are pinned as `flake = false` inputs; `nix flake update` bumps them.
- Repo-local skills live in `.agents/skills/<name>/` (the standard path pi reads) with a
  symlink from `.claude/skills/<name>` for Claude Code. See `.agents/skills/add-skill`.

## MCP servers

`home/packages/ai/mcp.nix` is the single place to declare an MCP server: home-manager's
`programs.mcp` feeds Claude Code (`enableMcpIntegration`), Codex (`mcp_servers` in
`config.toml`), and pi (`pi-mcp-adapter` reads `~/.config/mcp/mcp.json`). So a vendor's
"install our Claude Code plugin" instructions are usually just an MCP entry plus skills —
declare both here instead of running `/plugin install`, and all three agents get them.

## pi model configuration (`pi-models`)

`home/packages/ai/pi-coding-agent/models.json` is the single source of truth. `default.nix`
reads it with `fromJSON` and renders two files: `enabledModels` into `~/.pi/agent/settings.json`
and `providers` into `~/.pi/agent/models.json`. Both are store symlinks, so edit the repo file
and `make build` — never the deployed copies.

`pi-models` (`home/packages/shell/scripts/pi-models/`) edits that file: a Node server on a
random localhost port serving a single `app.html`, opened in the browser and stopped with
ctrl-c. Saving writes the repo file only; applying is still `make build`.

`pi-models --sync` (wired as `make models`) re-fetches the endpoints of every model that pins a
provider and rewrites only the limits that changed, printing a diff. It is the answer to
per-provider limits going stale: a pinned `contextWindow`/`maxTokens` is a snapshot, and nothing
in pi or OpenRouter refreshes it. If the pinned provider is gone it says so and changes nothing,
rather than silently falling back to another one.

Per pi's `docs/models.md`, a custom model in `models[]` with the same id *replaces* the built-in
entry and drops its pricing and metadata, while `modelOverrides` merges on top. Built-in
providers (those in `~/.pi/agent/models-store.json`) therefore use `modelOverrides`; `models[]`
is only for genuinely custom ones like lmstudio.

Per-provider limits come from the per-model `endpoints` call, not `/api/v1/models` — the latter's
`top_provider` describes whichever provider OpenRouter ranks first, which is wrong as soon as
`openRouterRouting.only` pins a different one. The endpoint `tag` is `provider/quant`
(`novita/fp8`); a bare `only: ["novita"]` accepts any quantization from that provider.

## Spoken responses (`speak`)

`speak` (`home/packages/shell/scripts/speak.py`) streams text to ElevenLabs and plays audio
while it is still being generated. The pi extension `speak.ts` is a thin pipe: it forwards
assistant `text_delta` events into `speak --stream` and owns nothing else. Toggle with
`/speak`; defaults from `PI_SPEAK`, voice/model from `SPEAK_VOICE` / `SPEAK_MODEL`.

Decisions worth not re-deriving:

- **Websocket `stream-input` with `auto_mode=true`**, not the HTTP `/stream` endpoint. One
  connection per turn gives gapless audio; a request per sentence would produce audible seams
  and re-pay latency each time. `auto_mode` lets ElevenLabs pick sentence boundaries, so the
  client never has to buffer for prosody.
- **One process per turn, not per assistant message** — the model resumes talking after tool
  calls, and a process per message overlaps. The child is respawned on demand because a long
  turn can outlive the websocket's 180s inactivity cap.
- **Markdown is stripped before speaking** (`Sanitizer`), statefully, because fenced code
  blocks span lines and are unlistenable; a fence becomes the words "code block".
- **`mpv --no-terminal` is mandatory** — `speak` runs inside TUIs and mpv otherwise grabs the
  terminal and corrupts the interface.
- **Thinking blocks are not read out**; the first one per turn plays a cached earcon instead,
  generated once into `~/.cache/speak/` since it never changes.
- The ElevenLabs MCP server and the `generate-speech` skill are unrelated to this — they exist
  for producing audio assets (demo videos), not for listening to responses.

## Hammerspoon pickers

Three plain modules under `home/dotfiles/hammerspoon/` back every picker, so the awkward parts
exist once:

- **`canvas.lua`** — the UI. `hs.chooser` was dropped because it is a native `NSTableView` in
  system font, clashing with the alerts and prompt drawn from `hs.alert.defaultStyle`;
  `canvas.picker` is the same rounded box, font and border as everything else. Only one modal
  exists at a time — `prompt` and `picker` share the canvas, the keyDown tap and the editing
  keys.
- **`task.lua`** — `task.run(path, args, done, onError)`, the only place that spawns processes.
- **`frecency.lua`** — `frecency.new(settingsKey)` giving `scores()` and `remember(id)`.

Consumers are rendered by nix because they need store paths: `.hammerspoon/rbw.lua`,
`.hammerspoon/spotctl.lua` and `.hammerspoon/bookmarks.lua` in `home/mac/hammerspoon.nix`.
`recursive_binder.lua` wires them with `pcall(require, …)`, so a module that was not rendered is
simply absent rather than an error.

- **`hs.task` needs a stream callback for anything over 64k.** Without one it only drains the
  pipe after the process exits, so a child that fills the 64k pipe buffer blocks in `write()`
  and never terminates — the completion callback never fires and *nothing* is reported, since
  every error path runs through that callback. `rbw list --raw` is ~128k, so it deadlocked
  every time. Diagnosis: `ps` shows the stuck children under Hammerspoon's pid, and
  `sample <pid>` puts `write` at the top of the stack. The final stream call can arrive after
  the completion one, hence the `hs.timer.doAfter(0, deliver)` handshake.
- **`hs.task` is held in a module-level table.** It is userdata with a `__gc` and can be
  collected mid-flight if the only reference is a local that goes out of scope.
- **`hs.canvas` pins text to the top of its frame**, it does not centre vertically. Anything
  that should look centred has to have its frame's `y` computed from the leftover space.
- **The box is one `strokeAndFill` rectangle over the whole canvas, exactly like `hs.alert`.**
  A canvas stroke is centred on its path, so the outer half is clipped and `strokeWidth = 4`
  reads as 2 — which is what every alert and the RecursiveBinder helper look like. Insetting
  the stroke to make it fully visible draws a border twice as thick as the rest of the UI.
- **The keyDown tap swallows every keystroke while a modal is up**, so its handler runs inside
  a `pcall` that tears the modal down on error — otherwise a Lua bug locks the keyboard until
  Hammerspoon is reloaded.
- Backspace is utf8-aware (walks back over `10xxxxxx` continuation bytes); `sub(1, -2)` would
  cut accented characters in half.
- Fuzzy matching is a local subsequence scorer (consecutive hits and early matches score
  higher, a hit on the name outranks one that needed the subtext). `string.find` is called with
  `plain = true`, so `.` and `%` in a query stay literal. Equal scores break on name length
  before alphabetically — `google.com` and `google cloud` score identically for "google", and
  the shorter one is the better answer.
- **Frecency is the caller's business:** a choice may carry a numeric `boost` added to its
  score, and with an empty query it *is* the ordering. `frecency.lua` supplies it from a
  decaying use count in `hs.settings` (zoxide-style: ×4 within the hour, ×2 within the day,
  ×0.5 within the week, ×0.25 after), capped at 30 so it breaks ties between comparable
  matches without ever outranking a plainly better one. `scores()` snapshots the counts once
  per picker rather than reading settings per candidate.
- **`onAlternate` is a variant of the main action on the highlighted row, bound to shift+return.**
  The binder cannot express it: which row it applies to is only known once something is
  selected, so unlike the vault's type/username/otp it cannot be a key chosen before the picker
  opens. Used to drill from a playlist into its tracks.
- The picker's box grows downwards from a fixed top edge, so the list does not jump as the
  query narrows it.

### Vault picker (`rbw`)

`rbw` (`home/packages/shell/rbw.nix`, every host) is the Bitwarden client for everything the
browser extension can't reach: native app clients, installers, the terminal. Its **agent keeps
the vault key in memory**, which is the whole reason it works behind a hotkey — the official
`bw` CLI is Node, starts in ~1s and needs `BW_SESSION` juggling. The Bitwarden desktop app is
not an option: system-wide auto-type on macOS has been "🔜" since 2018 and Windows is going
first. Bound at `cmd+space v` — `p` password, `t` type, `u` username, `o` otp.

- **The config is a read-only store symlink, so `rbw config set` fails** — edit `rbw.nix` and
  `make build`. This is safe only because rbw persists `device_id` in its *data* dir
  (`dirs::device_id_file()`), not back into `config.json`; a client that wrote to its own
  config would break under this module. It also means `sync_interval` cannot be set from nix:
  the home-manager module only exposes `email`, `base_url`, `identity_url`, `lock_timeout` and
  `pinentry`.
- **The picker reads the local db, and the agent only syncs every `sync_interval` (an hour by
  default)**, so an entry added from the browser would be invisible until then. `rbw sync` is
  fired in the background right after the picker opens, which costs nothing and means the next
  invocation is current.
- **`rbw list --raw` names the type field `type`, not `entry_type`** (there's a `serde(rename)`),
  and its values are `Login` / `Note` / `Card` / `Identity` / `SSH Key`. The picker filters to
  `Login` and keys choices on `id`, so duplicate entry names stay unambiguous — `rbw get`
  accepts a uuid as its needle.
- **Clipboard clearing is guarded by `hs.pasteboard.changeCount()`**, captured right after the
  write and re-checked after 30s: macOS bumps that counter on every write by anyone, so if
  something else was copied in the meantime the timer is a no-op instead of eating it.
- **Secrets are written with `writeAllData` under both `public.utf8-plain-text` and
  `org.nspasteboard.ConcealedType`** — Maccy and other clipboard managers honour that type and
  skip the item, so passwords never enter the history.
- **The "type" action exists because many native clients and installers refuse a paste.** It
  keeps a 0.2s delay so the picker's keyDown tap has fully stopped before `keyStrokes` posts
  its synthetic events.

### Playlist picker (`spotctl`)

Bound at `cmd+space m`. `spotctl playlist list` reads spotctl's sqlite cache without touching
the network — ~5ms, against ~1.1s for the three API pages 123 playlists need. spotctl keeps
Spotify's envelope, so the array is `items` (not `playlists`), holding trimmed
`{id, name, tracks, owner, public}` objects. Selecting runs `spotctl play playlist <id>`.

- **The read deliberately never checks freshness**, because a freshness test that reaches the
  network is exactly the latency the cache exists to remove. `spotctl playlist list --refresh`
  runs behind the picker instead: this invocation stays instant, the next one is current.
- **Requires spotctl newer than v0.9.0.** `playlist list` was an API passthrough until then, so
  the picker breaks until the tool is released and `nurPkgs.spotctl` is bumped.
- **Every spotctl command answers in JSON, errors included** (`{"error": …}`), so the error path
  decodes it rather than showing raw JSON in an alert.

### Bookmark picker (`linkding`)

Bound at `cmd+space l`, where a submenu of seven hardcoded `openURL` entries used to be. Those
seven live in linkding tagged `daily`, and frecency floats them back to the top within days.
`bookmarks.lua` talks to linkding over `hs.http` with the token from
`sops.secrets.linkding_api_token`, caching rows in `~/.cache/hammerspoon/bookmarks.json`.

- **Archived means kept, not done.** linkding carries two collections that are the same thing
  for us: the active endpoint is the read-later firehose (~10k, 87% of it YouTube), and
  archiving is how a link is promoted to a real bookmark. The picker therefore reads
  `/api/bookmarks/archived/` — 410 rows and 233KB in one request against 10k rows, 12MB and 11
  pages. The inversion is deliberate: the archive was completely unused (1 entry in 10,095), so
  spending it costs nothing, and it is the only *structural* split linkding offers. Tags could
  not do the job — the auto-tagger produced 2177 of them, and the large ones are 100% YouTube.
- **Never turn the refresh into a `modified_since` delta.** Archiving and unarchiving move a
  bookmark *between* endpoints rather than editing it, so a delta on either one never reports
  it and the cache drifts until something forces a full pass. The collection is small enough to
  refetch whole, which cannot drift. This was a real bug in the first version.
- **The cost is `hs.json.decode`, not the matching.** Measured on 10k rows: reading the cache
  0.5ms, building the rows 6.8ms, ranking per keystroke 14ms — but decoding ~2MB into Lua
  tables one element at a time through the ObjC bridge is what made the picker take seconds to
  appear. Rows are built once by `prime()`, scheduled with `hs.timer.doAfter(0, …)` so it lands
  off the critical path, and a keypress only reapplies frecency boosts to rows that already
  exist.
- **linkding's `q=` cannot negate.** `-youtube.com` matches nothing (it is read as a literal
  term), `!unread` means *is* unread rather than the opposite, `!untagged` does work, and
  `!archived` is not a filter at all. Archive state is an endpoint, not a query parameter —
  `?is_archived=true` is silently ignored.
- **Bundles are saved filters** (`search`, `any_tags`, `all_tags`, `excluded_tags`), and
  `?bundle=<id>` composes with either endpoint. Unused so far: if the archived collection ever
  grows unwieldy, a bundle on a positive tag is the escape hatch. A *negative* bundle is not
  expressible, which is why the split is the endpoint rather than a filter.

## Herdr patches

Herdr runs from a **fork**, `samirettali/herdr` branch `patched`: one commit per feature on top
of the released tag, checked out at `~/dev/herdr` (`origin` is upstream, `fork` is the fork).
`herdr.nix` keeps the NUR package vanilla and only swaps its `src` for the `herdr-fork` flake
input, so the rev is pinned in `flake.lock` and `nix flake update` bumps it. The fork's README
documents every option.

The five commits add: per-component `[theme.custom]` tokens (`space_*`, `agent_*`, `tab_*`,
`sidebar_divider`, each falling back to the palette token that component used before, with an
unset `agent_inactive_bg` leaving those rows unpainted); a `spacer` sidebar token that eats the
row's leftover width so what follows renders flush right, one column in; `[ui.tab_bar]` with
`label_padding`, `gap` and `min_width`, where the padding default of 2 is symmetric against
vanilla's 1 left and 3 right; `[ui] pane_outer_border`, which drops every border edge facing no
other pane — there is no frame widget, the outer border *is* the perimeter of the per-pane
boxes — and with it every border title, since titles live inside a top border and only some
panes keep one; and `[session] restore_commands`, which records a pane's foreground argv when
its executable is allowlisted and re-runs it through the deferred agent-resume path, because a
cold restore otherwise hands every pane a bare shell (`launch_argv` is saved but only replayed
on an fd handoff).

- **Release bump:** rebase `patched` on the new tag, push, `nix flake update`. Nothing is
  exported into this repo any more — the branch is the only source of truth. There used to be
  five `.patch` files here and the two copies did drift once, with the checkout holding a
  stale, partial version of the theme-tokens work.
- **Only `src` is overridden, not `cargoDeps`**, which the NUR derivation still computes from
  upstream's source. That works while the fork leaves `Cargo.lock` untouched, and fails loudly
  (the vendor hook compares the lock) if a commit ever adds a dependency.
- **Herdr can't be built with a bare `cargo build` on darwin**: `build.rs` runs `zig build` for
  the vendored libghostty-vt, and nixpkgs' zig cannot link natively outside the nix stdenv (it
  fails on undefined libc symbols like `_malloc`, with or without `SDKROOT`/`ZIG_LIBC`). To run
  Herdr's test suite, build the package with `doCheck = true` via `overrideAttrs` instead:
  `nix build --impure --expr` over `overrideAttrs (_: { src = …; doCheck = true;
  cargoTestFlags = ["--bin" "herdr"]; })`. Failing assertions print
  in the nix log, which is the only feedback loop available. Compile errors too — there is no
  fast `cargo check`, so a missed call site costs a full four-minute build.
- **Run the suite unfiltered and diff the failures against unpatched herdr.** In the nix sandbox
  ~44 tests fail on their own (read-only `$HOME`, git, sockets, network — hence upstream's
  `doCheck = false`), plus a couple of `server::*` async tests that flake between runs, so a
  raw failure count says nothing. Filtering hides real breakage: `checkFlags = ["sidebar"]`
  passed clean while the theme-tokens patch was silently failing two tab bar tests.
- **`PoisonError { .. }` failures are collateral, not breakage.** Herdr's tests share a mutex
  around the process environment, so one of the sandbox-broken tests panicking while holding it
  poisons the lock for every later test that takes it — once seen as 20 extra failures across
  `config::io` and `detect::manifest` that all passed when run in isolation. Which tests get hit
  varies between runs. Re-run the suspicious modules on their own with `checkFlags` before
  believing them.
- **`herdr server live-handoff` swaps the binary without killing the panes** — the old server
  passes its pane fds to the new one, so agents keep running. Check `capabilities.live_handoff`
  in `herdr status --json` first; `herdr server stop` is the destructive alternative. Untested
  here. Max 64 panes per handoff.
- Herdr's own `config.toml` is deliberately **not** managed by nix (it changes too often); it
  lives at `~/.config/herdr/config.toml` and the `xdg.configFile` block in `herdr.nix` stays
  commented out.

### Pending agents in sketchybar

`items/herdr.lua` shows the agents waiting for you — `blocked` and `done`, never `working` or
`idle` — as two counts, and opens a popup with one clickable row per agent. The counts are
pushed by `herdr-sketchybar` (`home/packages/shell/scripts/`), a LaunchAgent declared in
`home/mac/sketchybar.nix` that holds Herdr's socket open and triggers the `herdr_agents` event.
Nothing polls.

- **`pane.agent_status_changed` requires a `pane_id`; there is no global variant.** So the
  watcher subscribes once per agent pane, plus the parameterless lifecycle events
  (`pane.created/closed/exited/agent_detected`), and **reconnects whenever the set of agent
  panes changes** — which also avoids depending on whether a second `events.subscribe` on the
  same connection is additive, something that was never confirmed. The global alternative,
  `pane.updated`, measured ~10 messages a second on a busy session: a timer in disguise.
- **Counts come from `herdr agent list` on every event, not from the payload.** An event says
  one pane changed, not how many are waiting, so totals accumulated from events drift after any
  missed message.
- **The per-row detail goes through `~/.cache/sketchybar/herdr-agents.json`, not the event.**
  Pane ids contain `:` and titles arbitrary punctuation, so packing them into `--trigger`
  variables would mean inventing an encoding. Written before the trigger, so the item can never
  read rows that disagree with the count.
- **`herdr agent focus <pane_id>` jumps to a pane, `herdr pane focus` is directional**
  (`--direction left|right|up|down`) and just prints usage when handed an id — silently, since
  a `click_script`'s stderr goes nowhere. The row also runs `open -a Ghostty`: focusing only
  moves Herdr's own focus, which is invisible if the terminal is not in front.
- **A LaunchAgent inherits almost no environment, and with `useUserPackages` the user profile
  is `/etc/profiles/per-user/$USER/bin`, not `~/.nix-profile/bin`.** Guessing the latter left
  the watcher counting zero forever. Both `herdr` and `sketchybar` are on `PATH` by store path
  now, which is why the patched package lives in its own `herdr-package.nix` — and every
  failure is logged, because this one was mute.

## Gotchas

- **SbarLua's `sbar.exec` callback receives a *table*, not a string, when the command's
  stdout is valid JSON** (`callback_function` in `sketchybar.c` runs it through
  `json_to_lua_table` first). Calling `cjson.decode` on it silently raises inside the
  callback — the bar keeps running, nothing is logged, the item just never updates.
  Handle both types.
- **`xps` full eval / `nix flake check` currently fails** on a pre-existing nixpkgs
  insecure-package gate (`nodejs-slim`), unrelated to most changes. `mbp` evaluates clean.
- **Verify tool config against the installed version, not memory** — e.g. lazygit moved
  `git.paging` → `git.pagers` (array); difftastic's HM module writes `programs.git.enable`,
  so gating `difftastic.enable` on `config.programs.git.enable` causes infinite recursion.
- **Firefox/gwfox needs `sidebar.visibility = "hide-sidebar"`.** gwfox styles the collapsed
  vertical-tabs sidebar — and the floating urlbar that `gwfox.urlbar` moves into it — only
  inside `@media -moz-pref("sidebar.visibility", "hide-sidebar")`. Under the default
  `always-show` the collapsed state has no rules at all: Firefox keeps reserving the launcher
  strip and cmd+L focuses an urlbar that is positioned nowhere.
- **Never patch gwfox's `userChrome.css`** — it is one deeply nested CSS-nesting tree, so a
  patch hunk's context lands wherever it happens to sit after an update; a previous
  collapsed-sidebar patch silently ended up nested inside the `hide-sidebar` media query and
  never applied. Overrides go in `gwfox-overrides.css`, appended by the `gwfoxUserChrome`
  derivation, so they are always top-level.
- **Firefox extensions are installed by enterprise policy**, not `extensions.packages`: their
  `install_url` is a store path, which changes on every bump, so Firefox reinstalls. Symlinking
  XPIs into the profile does not work — there Firefox decides from an mtime that is 1000ms on
  every store file, so no update is ever detected. Policies are read **only at startup**, so a
  switch that changes them needs Firefox restarted from `~/Applications/Home Manager Apps`;
  relaunching a bundle macOS still has cached leaves the extensions gone, since the profile
  symlinks are removed immediately but nothing installs them.
- **Never lock a pref through the `Preferences` policy.** `Policies.sys.mjs` calls
  `lockPref` outside the `try` that writes the value, so a write that fails still locks the
  pref — at Firefox's own default. Locking
  `toolkit.legacyUserProfileCustomizations.stylesheets` this way left it locked to `false`:
  `userChrome.css` was never loaded and the whole theme vanished, vertical tabs included.
  Prefs belong in `settings`, which renders `user.js`.
- **`extensions.settings` is inert**, and `sidebar.main.tools` has to name the extension.
  Declaring any extension setting makes home-manager force
  `extensions.webextensions.ExtensionStorageIDB.enabled = false` for *every* extension —
  Bitwarden then keeps its whole vault in one 2MB JSON file — so the pref is overridden back
  to `true`, which in turn means `browser-extension-data` is never read. See issue #11.
  Separately, Firefox appends any extension declaring a `sidebar_action` to
  `sidebar.main.tools`, so leaving that pref unset lets a rebuild drop Bitwarden's panel.
- **Debug Firefox's chrome by measuring it, not by reading gwfox.** The `firefox` skill
  drives the browser over its remote debugging protocol; `rdp.py rules <sel> <prop>` names
  every rule setting a property and which one wins, and `measure` prints the box chain. Two
  traps that look like specificity but are not: descendant combinators never cross a shadow
  boundary, so rules for anything inside `sidebar-main` must be top-level, and
  `visibility: hidden` makes an element unfocusable — hiding the urlbar that way breaks
  cmd+L.
