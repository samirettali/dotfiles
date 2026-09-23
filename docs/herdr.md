# Herdr

Read this before changing the patched Herdr package or its Neovim integration.

## Fork and package

Herdr runs from `samirettali/herdr`, branch `patched`.
The checkout is `~/dev/herdr`, with upstream as `origin` and the fork as `fork`.
Keep one commit per feature above upstream `master`.
The fork's README is the source of truth for every added option.
The pre-0.9 branch, with the sidebar and tab patches that were dropped, is `patched-0.8.2`.

`herdr-package.nix` builds the fork from its own `nix/package.nix`, through the `herdr-fork` flake input.
`flake.lock` pins the fork revision.
The package reads `Cargo.lock` from the tree, so the NUR `herdr` package and its hashes play no part:
the NUR stays vanilla Herdr for anyone else, and updating it cannot break this build.
The work Mac installs the same revision through `samirettali/tap/herdr`, pinned in `homebrew-tap`.

To update:

1. Rebase `patched` onto upstream `master` and push the fork branch.
2. Run `nix flake update herdr-fork` in this repository.
3. Bump `revision` in the tap formula.
4. Run `pkgs/herdr/update.sh` in the NUR when it should follow, independently of the fork.

Do not export patch files back into this repository.
The branch is the only source of truth.

## Agent integrations and ownership

The fork contains its integration assets under `src/integration/assets/`.
`herdr integration install <agent>` writes those files and, where needed, edits
agent settings. It is an imperative installer, not the source of truth here.

Home Manager takes the assets directly from `inputs.herdr-fork`, so a fork bump
updates both the binary and its integrations. The agent modules own registrations:

| Agent | Managed asset | Registration |
| --- | --- | --- |
| Pi | `.pi/agent/extensions/herdr-agent-state.ts` | Pi's global extension discovery |
| Claude | `.claude/hooks/herdr-agent-state.sh` | `settings.json`, `SessionStart` |
| Codex (personal machines) | `.codex/herdr-agent-state.sh` | `hooks.json`, `SessionStart` |

Do not run the integration installer over these store-backed files: it attempts
to write them. Change registrations in the corresponding Nix module, and update
assets through the fork input. Pi and Codex use `force` only on these exact
managed paths to replace the previous manually installed files on activation.
No activation hook runs Herdr's installer.

`herdr-session-title.ts` is a separate, repository-owned Pi extension; Herdr does
not install it. It remains alongside the upstream state integration. Other
harness integrations are not enabled merely because the fork ships an asset.
The work Mac receives only the Claude asset through `make chezmoi`.

After a fork update, run `make check-herdr` to smoke-test the shell hooks against
an isolated socket and exercise the fork's Pi integration tests. Then inspect
the rendered Claude registration. These tests never contact the live Herdr
server. Runtime validation after an approved switch is separate.

## Building and testing on Darwin

A bare `cargo build` does not work on Darwin.
`build.rs` invokes Zig for vendored libghostty-vt, and nixpkgs' Zig cannot link it outside the Nix stdenv.

Build through Nix with `doCheck = true` using `overrideAttrs`.
Use `cargoTestFlags = ["--bin" "herdr"]` and inspect failures in the Nix log.
There is no useful fast `cargo check` loop here.

Before changing a signature, search every call site and update them in one pass, including tests.
Each missed compiler error otherwise costs another full Nix build.

Run the suite unfiltered and compare failures with an unpatched Herdr build.
The sandbox causes expected failures involving a read-only home, Git, sockets, and network access.
Some async server tests also flake.
A raw failure count does not establish a regression.

A panic while holding Herdr's shared environment mutex can poison later tests.
Treat `PoisonError { .. }` failures as collateral until the affected module also fails in isolation.

## Live handoff

`herdr server live-handoff` replaces the server without killing panes.
Check `capabilities.live_handoff` in `herdr status --json` first.
`herdr server stop` is the destructive alternative.
The handoff supports more than 64 panes when the sending server is at least 0.9.1.

## Pane border and tab colours

`[theme.custom] pane_active_border` and `pane_inactive_border` change only the pane borders and
fall back to `accent` and `overlay0`, which remain available for the other interface elements.
`tab_active_bg`, `tab_active_fg`, `tab_inactive_bg` and `tab_inactive_fg` do the same for the
tab bar. Sidebar tokens take an inline `fg` upstream, and `active_row_bg` paints active rows.

## Navigation between Herdr and Neovim

Herdr binds `focus_pane_*` to `ctrl+hjkl` without a prefix.
Normally those bindings would prevent Neovim from seeing the keys.

`[keys] passthrough_commands = ["nvim"]` forwards only those directional chords while
Neovim owns the foreground process group.
`keymaps.lua` first moves between Neovim windows.
At an outer edge it runs `herdr pane focus --direction ...`.
This mirrors the foreground-process split used by `vim-tmux-navigator`.

- Check the foreground process on every keystroke instead of caching it.
  `:sh` and `Ctrl-Z` must change ownership immediately.
- Pass through only the four directional keys.
  Direct custom commands and prefixed bindings must remain available as an escape path.
- Start the Herdr CLI through `vim.system{}` without `:wait()`.
  Edge navigation is fire-and-forget and should not pay CLI latency.
- Guard the integration with `HERDR_PANE_ID`.
  The same keymap in a plain terminal must do nothing.
- Accept that shells and agent panes lose `ctrl+l`, `ctrl+k`, and `ctrl+j`.
  This is the same tradeoff tmux makes for equivalent navigation.
