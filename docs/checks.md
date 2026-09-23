# Repository checks

`make check` is the local pre-merge contract. It does not activate a host, update
inputs, modify bookmarks or call paid APIs. Start from the tools installed on
mbp; individual targets are useful while iterating:

| Target | What it checks | Requirements |
| --- | --- | --- |
| `make check-fmt` | Alejandra, read-only | Git, Alejandra |
| `make check-lint` | deadnix and Statix | Git, deadnix, Statix |
| `make check-tests` | Fish prompts, Git ignores, `gd` ownership, file selection, browser log filtering | Node, Fish, Nix, Git, lint tools |
| `make check-pi` | X Search loaded through the pinned Pi runtime, with mocked HTTP | Nix, Node, flake inputs |
| `make check-herdr` | Shell hooks on a test socket and the pinned fork's integration tests | Nix, Node, Bun, Python 3 on PATH for upstream hooks |
| `make check-eval` | mbp system and andromeda activation derivations | Flake inputs available locally |
| `make check-chezmoi` | Render in a temporary copy and diff against `chezmoi/` | Darwin builder, Nix, Bash, rsync, jq |

Host evaluation does not build or activate either configuration. The chezmoi
check builds only Home Manager's file tree, not the full system, and leaves the
working tree unchanged. If it reports drift, run `make chezmoi` and review the
rendered diff. Both targets disable lock-file writes. Input fetching and missing
store dependencies can still require network access; "offline" describes the
test cases, not bootstrapping the toolchain.

`make fmt` is the explicit formatting command. Format and lint use Git's cached
file list, handle spaces and deleted files, and never recursively walk worktrees,
result links or untracked artifacts. Run `git add -N <new-file>` to include a new
file in both checks and flake evaluation.

## Pi runtime tests

`make check-pi` builds the current platform's Pi package from the locked NUR input
without activating Home Manager or writing the lock file. It passes the store
path as `PI_TEST_PACKAGE`; the test uses Pi's own extension loader rather than
maintaining a second set of dependency aliases. An installed Pi configuration
and links under `~/.pi/agent/extensions/node_modules` are not required.

Pi supplies the SDK and TypeBox aliases when loading extensions. Our current
extensions therefore need no deployed `package.json`, `tsconfig.json`, or
`node_modules` links. Those files would not configure TypeScript editing in the
repository anyway; a source-tree development setup is separate and deferred.
The NUR wrapper already disables telemetry and update checks. The old
`PI_AI_MODULE_PATH` and `PI_AI_OAUTH_MODULE_PATH` overrides belonged to the retired
native web-search skill, not Pi's loader.

Keep `~/.pi/pi-source` and the `PI_PACKAGE_DIR` override: they give agents readable
paths to the installed documentation and examples rather than long store paths.

## Small CI

`.github/workflows/check.yml` runs `make check-ci`: format, lint and portable
offline tests. It obtains tools from the public nixpkgs revision already recorded
in `flake.lock`, without evaluating the dotfiles flake. The latter has a private
SSH input, so running complete host evaluation in credential-free CI would not
work on a cold runner. CI has read-only repository permission, no stored checkout
credentials, no secrets, and no system build matrix.

Pi-runtime tests, Herdr tests, host evaluation and the full Darwin chezmoi render
remain explicit local gates in `make check`, not silently skipped CI jobs. Browser
CDP integration is opt-in: set `BROWSER_BIN` and `BROWSER_SKILL_SCRIPTS` to the
built skill when running `browser.test.mjs` directly. `make check-tests` clears
`BROWSER_BIN` so it never launches a browser implicitly.

## Home Manager-only Linux hosts

On a non-NixOS Linux host, `make build` now builds
`homeConfigurations.<hostname>.activationPackage` and executes its `activate`,
the same approach as `servers/ansible/roles/home-manager/tasks/main.yml`.
`make build` is still an activation command and requires the usual approval.

To inspect the andromeda command without running it:

```sh
make -n build OS=Linux HOSTNAME=andromeda
```

From mbp, `make check-eval` validates the Linux derivation without requiring a
Linux builder or activating anything.
