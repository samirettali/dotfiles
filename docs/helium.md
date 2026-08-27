# Helium

Read this before changing the browser, its extensions, or anything that drives a
browser from an agent.

Helium is a Chromium fork with Google's services taken out. That is the point of
it, and also the cost: the Web Store and the component updater are gone, so
extensions and the Widevine CDM have to arrive from the Nix store instead.

Three NUR packages and one module cover it:

| Piece | Where | What it is |
| --- | --- | --- |
| `helium` | NUR | The browser, re-signed ad-hoc on macOS |
| `widevine-cdm` | NUR | The CDM, fetched from Google's component updater |
| `chrome-extensions` | NUR | Pinned CRX files for the extensions I run |
| `helium.nix` | `home/packages/desktop/` | Puts the last two where Helium looks |

## Widevine

Helium is built with Widevine enabled but has no component updater, so it creates
`~/Library/Application Support/net.imput.helium/WidevineCdm` and never fills it.
DRM sites fail with `DRM_MEDIA_KEY_INITIALIZATION` until something else does.

Dropping the CDM in is necessary and not sufficient. Helium's helpers are signed
with the hardened runtime's library-validation flag, which outranks the
`disable-library-validation` entitlement the generic helper carries, so AMFI
refuses a library from another team:

```
code signature ... not valid for use in process: mapping process and mapped
file (non-platform) have different Team IDs
```

The `helium` package therefore re-signs the whole bundle ad-hoc, which clears the
flag. Upstream considers third-party CDMs unsupported and suggests the same thing
in [helium-macos#296](https://github.com/imputnet/helium-macos/issues/296).
`enableWidevine = false` keeps upstream's Developer ID signature instead.

The CDM has to sit in a directory named after its own version —
`WidevineCdm/4.10.3050.0/manifest.json` — because that is where the component
updater would have put it. The module reads the version from the package.

Verify it rather than trusting the browser's UI, which reports Widevine as
present either way:

```js
await navigator.requestMediaKeySystemAccess('com.widevine.alpha', [{
  initDataTypes: ['cenc'],
  videoCapabilities: [{contentType: 'video/mp4; codecs="avc1.42E01E"'}],
}]).then(a => a.createMediaKeys())
```

`CreateCdmFunc not available` means the CDM was found but refused; the reason is
in the browser's stderr under `--enable-logging=stderr --v=1`.

## What the ad-hoc signature costs

An ad-hoc signed application has no Team ID, so macOS identifies it by path — see
`docs/macos-tcc.md`. Two consequences, both on every version bump:

- Camera, microphone and screen recording grants are asked for again.
- The `Helium Safe Storage` Keychain item no longer matches the app, so the
  first launch prompts for the login password. Denying it leaves saved
  passwords and cookies in the profile undecryptable.

`BROWSER_BIN` points at the `copyApps` copy, not the store path, so an unrelated
rebuild does not move the browser out from under those grants.

## Extensions

An external extension that carries only a Web Store update URL is ignored here.
One that points at a CRX file on disk installs on the next launch. That is what
`External Extensions/<id>.json` holds, and why the CRX files are in the store.

They do not auto-update: Helium rewrites the update endpoint to
`helium-services-are-disabled.qjz9zk` and blocks the request. Updates come from
the NUR updater, which reads the version and the SHA-256 straight out of the Web
Store's update response.

To add one, put its ID and a short name in `pkgs/chrome-extensions/extensions.json`
in the NUR repo and run that package's `update.sh`.

Do not put a content blocker in that list: Helium loads uBlock Origin itself as
a component extension, and a second one only doubles the work on every page.

Firefox's list came over except `adaptive-tab-bar-colour`, which themes
Firefox's own chrome and has no Chromium counterpart.

## Agents

Nothing in the agent tooling knows or cares that this is not Chrome:

- The `web-browser` skill spawns `$BROWSER_BIN`.
- The `chrome-devtools` MCP server attaches to `--browserUrl=127.0.0.1:9222`, so
  it needs a browser started with `--remote-debugging-port=9222`, whichever one.

## The server

`andromeda` has its own browser, and it is not this one: Helium on Linux is an
AppImage, and headless it would only be the Chromium underneath it without the
extensions or the CDM that justify it here. `home/packages/dev/headless-browser.nix`
installs `ungoogled-chromium` from nixpkgs instead, which is substitutable for
aarch64-linux — 200 MB fetched, nothing built.

Two things that machine cannot do by itself, both settled in that module:

- The sandbox. nixpkgs points `CHROME_DEVEL_SANDBOX` at a setuid helper only a
  root-owned installation can provide, so chromium finds it, refuses to run
  unsandboxed and aborts. The `chromium` on `PATH` is a wrapper that passes
  `--no-sandbox`.
- Fonts. `fc-list` found nothing at all, so rendered text came out as empty
  boxes. The module installs DejaVu, Liberation and the Noto emoji font and
  turns on home-manager's fontconfig, with the generic families pinned —
  without that, `sans-serif` resolved to a serif face.

Chromium reads the home-manager fontconfig through XDG. Do not "fix" the
`Cannot load default config file` warning from `fc-list` by setting
`FONTCONFIG_FILE` to the store's `fonts.conf`: that config replaces the
home-manager one instead of adding to it, and rendering falls back to serif.
`fc-list` sees all the fonts despite the warning; `fc-match` does not, and lies
about which family wins. Trust a screenshot.

Before it existed, every session built its own chromium with `nix build
nixpkgs#ungoogled-chromium`, used it by store path and lost it to the next
garbage collection — roughly 5,800 chrome-devtools MCP calls' worth of that.

## Changing any of this

The packages live in the NUR repo, which dotfiles pins as a flake input. Merge
there first, then `nix flake update samirettali-nur` here. To try both at once
without pushing:

```sh
nix eval '.#darwinConfigurations.mbp.config.home-manager.users.samir.home.file' \
  --override-input samirettali-nur path:$HOME/dev/nur
```

The Linux build is packaged but unwired: neither the CDM nor the extensions have
been tried against the profile layout of the AppImage.
