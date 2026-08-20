# Herdr

Read this before changing the patched Herdr package or its Neovim integration.

## Fork and package

Herdr runs from `samirettali/herdr`, branch `patched`.
The checkout is `~/dev/herdr`, with upstream as `origin` and the fork as `fork`.
Keep one commit per feature above the released tag.
The fork's README is the source of truth for every added option.

`herdr.nix` keeps the NUR derivation and replaces only its `src` with the `herdr-fork` flake input.
`flake.lock` pins the fork revision.

To update for a release:

1. Rebase `patched` onto the new tag.
2. Push the fork branch.
3. Run `nix flake update` in this repository.

Do not export patch files back into this repository.
The branch is the only source of truth.

Only `src` is overridden, not `cargoDeps`.
The NUR derivation still computes dependencies from upstream.
This works while the fork leaves `Cargo.lock` unchanged and fails loudly when it does not.

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
The handoff supports at most 64 panes.

## Pane border colours

The focused pane border uses `accent`.
`[theme.custom] pane_inactive_border` changes only unfocused pane borders and falls back to
`overlay0`, which remains available for the other muted interface elements.

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
