# Firefox configuration

Read this before changing Firefox, gwfox, extensions, or browser chrome CSS.

## gwfox and the sidebar

Set `sidebar.visibility = "hide-sidebar"`.
gwfox styles its collapsed vertical-tabs sidebar only inside the matching preference media query.
The floating URL bar also depends on that state.
With `always-show`, Firefox keeps the launcher strip and can focus a URL bar positioned nowhere.

Never patch gwfox's `userChrome.css`.
It is one deeply nested CSS tree, so update context can place a patch inside the wrong rule without a conflict.
Put overrides in `gwfox-overrides.css`.
The `gwfoxUserChrome` derivation appends that file at top level.

## Extensions

Install extensions through enterprise policy, not `extensions.packages`.
The policy `install_url` points at a store path, so Firefox notices a changed package and reinstalls it.

Symlinking XPIs into the profile does not provide reliable updates.
Firefox sees the fixed Nix store mtime and does not detect a new package.

Firefox reads policies only at startup.
After a switch changes extension policies, fully restart Firefox from `~/Applications/Home Manager Apps`.
Relaunching a cached bundle can leave profile links removed before any extension gets installed.

Do not configure extension state through `extensions.settings`.
Home-manager then disables `extensions.webextensions.ExtensionStorageIDB` globally.
The configuration overrides that preference back to `true`, which makes `browser-extension-data` inert.
See issue #11.

Set `sidebar.main.tools` explicitly for sidebar extensions.
Firefox appends extensions with `sidebar_action` at runtime, but a rebuild can otherwise drop their panel.

## Preferences

Never set a Firefox preference through the `Preferences` enterprise policy.
Firefox can lock a preference even when writing its requested value fails.
The result is a preference locked at Firefox's default.

Put preferences in `settings`, which renders `user.js`.
This is especially important for
`toolkit.legacyUserProfileCustomizations.stylesheets`; locking its default disables
`userChrome.css`.

## Debugging browser chrome

Measure Firefox chrome instead of inferring CSS behavior from gwfox's source.
Use the `firefox` skill and its Remote Debugging Protocol client.

`rdp.py rules <selector> <property>` lists every matching declaration and identifies the winner.
`rdp.py measure` prints the relevant box chain.

Remember two non-specificity traps:

- Descendant combinators never cross a shadow boundary.
  Rules for content inside `sidebar-main` may need a top-level target.
- `visibility: hidden` makes an element unfocusable.
  Hiding the URL bar this way breaks `cmd+L`.
