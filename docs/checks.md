# Repository checks

`make check` is the local pre-merge contract. It does not activate a host, update
inputs, modify bookmarks or call paid APIs. Start from the tools installed on
mbp; individual targets are useful while iterating:

| Target | What it checks | Requirements |
| --- | --- | --- |
| `make check-fmt` | Alejandra, read-only | Git, Alejandra |
| `make check-lint` | deadnix and Statix | Git, deadnix, Statix |
| `make check-tests` | Fish prompts, Git ignores, `gd` ownership, JavaScript profiles, file selection, browser log filtering | Node, Fish, Nix, Git, lint tools |
| `make check-pi` | Type-check all local Pi extensions, then test X Search with mocked HTTP | Nix, flake inputs |
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

`make check-pi` enters the development shell, which provides the current
platform's Pi package from the locked NUR input as `PI_TEST_PACKAGE`. It prepares
an ignored source-tree dependency link and runs TypeScript checks before the
mocked HTTP tests, without activating Home Manager or writing the lock file.
The tests use Pi's own extension loader rather than maintaining a second set of
runtime aliases. An installed Pi configuration and links under
`~/.pi/agent/extensions/node_modules` are not required.

Pi supplies the SDK and TypeBox aliases when loading extensions. Our current
extensions therefore need no deployed `package.json`, `tsconfig.json`, or
`node_modules` links. Those files would not configure TypeScript editing in the
repository anyway; the separate [development setup](ai/pi-development.md) puts
them next to the sources instead.
The NUR wrapper already disables telemetry and update checks. The old
`PI_AI_MODULE_PATH` and `PI_AI_OAUTH_MODULE_PATH` overrides belonged to the retired
native web-search skill, not Pi's loader.

Keep `~/.pi/pi-source` and the `PI_PACKAGE_DIR` override: they give agents readable
paths to the installed documentation and examples rather than long store paths.

## CI

`.github/workflows/check.yml` has two jobs, with read-only repository permission
and no stored checkout credentials.

`offline-checks` runs `make check-ci`: format, lint and portable offline tests. It
obtains tools from the public nixpkgs revision already recorded in `flake.lock`,
without evaluating the dotfiles flake, and has no secrets.

`evaluate` runs `make check-eval-andromeda` on `ubuntu-24.04-arm` and
`make check-eval-mbp` on `macos-latest`. The flake has a private SSH input,
`samirettali/skills`, so the job loads a read-only deploy key from the
`SKILLS_DEPLOY_KEY` secret, which the infra repository generates and declares in
`github/deploy-keys.tf`. Each host evaluates on its own platform because
`pi-mcp-adapter` and `pi-provider-kimi-code` in the NUR use `importNpmLock`, which
reads the npm lock file from their source during evaluation. Pull requests from
forks get no secrets, so they skip this job.

Pi-runtime tests, Herdr tests and the full Darwin chezmoi render remain explicit
local gates in `make check`, not silently skipped CI jobs. Browser
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
