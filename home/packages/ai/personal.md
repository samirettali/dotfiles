## Tools on my own machines

- rbw — Bitwarden CLI
- fluxctl — Miniflux CLI, my RSS reader
- linkctl — linkding CLI, my bookmarks
- nix and home-manager — everything declared
- NUR — where I publish my own packages

## Working on my own machines

- On `andromeda`, dev servers bind to `0.0.0.0`, including through `make dev`, so I reach them at `http://andromeda:<port>` from my Mac without forwarding ports. Binding is not enough for Vite: it rejects unknown Host headers, so `server.allowedHosts` must always include `andromeda` in dev.
- My CLI wrappers (`firecrawl`, `generate-*`, `x-search`) take their keys from the environment or the rbw vault. Never print, store or pass a key as an argument. If the vault is locked, ask me to unlock it; do not set up another credential store, run a login or installer, or fall back to keyless access.
