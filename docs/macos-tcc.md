# macOS permissions and store paths

Read this before changing how a GUI application launches, especially from launchd.

A properly signed application keeps Accessibility and Screen Recording grants across path
changes because macOS recognizes its signature.
An ad-hoc signed application without a Team ID falls back to path identity.
Moving that application to a new Nix store path silently invalidates its grant.
The process can keep running while the protected capability stops working.

`targets.darwin.copyApps` copies real application bundles into `~/Applications/Home Manager Apps`.
It uses checksums, so unchanged bytes remain at a stable path across rebuilds.
Launching through Spotlight, the Dock, or `open -a` uses that stable copy.

## Launch paths

Anything that starts an ad-hoc application by store path defeats `copyApps`.
The home-manager launchd module normally embeds `${cfg.package}/Applications/...`.

`aerospace.nix` therefore forces `launchd.agents.aerospace.config.Program` to the copied application path.
AeroSpace is the only application bundle currently launched by an agent.
Other agents run CLI binaries, which do not need these GUI grants.

Store-path wrappers are harmless for applications signed with a stable Team ID.
`BROWSER_BIN` can therefore point at the Nix store for signed Chrome builds.

## Diagnosis and recovery

Diagnose the protected capability instead of trusting System Settings.
For AeroSpace, `aerospace list-apps` uses NSWorkspace and works without Accessibility access.
`aerospace list-windows --all` uses the Accessibility API and returns no windows without the grant.
A live server with a loaded configuration and zero windows indicates a permission identity problem.

Toggling the existing checkbox may not help.
Launch Services can retain registrations for old store paths and display identical application names.

Reset only AeroSpace's grant with:

```sh
tccutil reset Accessibility bobko.aerospace
```

Then launch the stable copied application and grant access again.

An application upgrade still changes its cdhash and can require one new grant.
Avoiding that requires a real signing identity.
