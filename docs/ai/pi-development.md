# Developing Pi extensions

Edit `home/packages/ai/pi-coding-agent/extensions/`, not the store-backed files
under `~/.pi/agent/extensions/`.

## Editor setup

The JavaScript `minimal` and `full` profiles install
`typescript-language-server` and enable Neovim's native `ts_ls`. ESLint remains
exclusive to `full`. Apply profile changes with the usual `make build`, then
restart Neovim.

From the repository root, allow the development environment once:

```sh
direnv allow
nvim home/packages/ai/pi-coding-agent/extensions/x-search.ts
```

Alternatively, enter `nix develop` without enabling direnv. Both prepare the
same environment. Each worktree gets its own ignored dependency link.

`package.json` and `tsconfig.json` next to `default.nix` define the source-tree
TypeScript project. `shell.nix` links its `node_modules` to a Nix-store tree
containing Pi's SDK, Pi AI, Pi TUI, TypeBox and Node types from the locked Pi
package. No `npm install`, npm lockfile, or second copy of Pi is needed. The shell
refuses to overwrite a real dependency directory or an unrelated symlink.

The development shell also provides `tsc` from the same TypeScript major used by
the packaged language server. The link is refreshed when direnv reloads or the
shell is entered after a flake update. Nothing here adds files to the installed
Pi extension directory.

## Verification

`make check-pi` enters the development shell, checks every local extension with
`tsc --noEmit`, then runs the mocked X Search tests through Pi's real loader. It
prepares only the ignored dependency link, does not activate the host, and does
not write `flake.lock`.

The initial setup was also verified with headless Neovim using the repository's
`ts_ls` configuration and native LSP attach hooks: API completion, hover, `gd`
(including the native quickfix result list), and a deliberately introduced type
error that disappeared after restoring the buffer without saving.
