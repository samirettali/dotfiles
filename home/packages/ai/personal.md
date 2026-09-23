## Tools on my own machines

- lazydocker — docker
- rbw — Bitwarden CLI
- fluxctl — Miniflux CLI, my RSS reader
- linkctl — linkding CLI, my bookmarks
- sops — secrets
- nix and home-manager — everything declared
- NUR — where I publish my own packages
- agy (Antigravity CLI) — work outside the code: LinkedIn links, notes from podcasts and YouTube tech talks into the Obsidian vault, throwaway scripts that are not meant to stay. On trial: whether it writes code well is still an open question.

## Where I keep things

Three places, three lifetimes. Put a link where it belongs, and do not propose
deleting something that belongs somewhere else.

- linkding, unarchived — read later and watch later. A queue, not a collection:
  everything here is meant to leave, either read or deleted.
- linkding, archived — functional links: sites I use often, online tools,
  documentation and product pages I come back to. These are not reading, so
  never judge them by how interesting the title is.
- `Clippings/` in the Obsidian vault — articles and media worth rereading and
  rewatching, more than once. This is the part that lasts.

When triaging, a functional link in the queue is misfiled, not noise: archive it
instead of deleting it.

## Working on my own machines

- On `andromeda`, dev servers bind to `0.0.0.0`, including through `make dev`, so I reach them at `http://andromeda:<port>` from my Mac without forwarding ports. Binding is not enough for Vite: it rejects unknown Host headers, so `server.allowedHosts` must always include `andromeda` in dev.
- My CLI wrappers (`firecrawl`, `generate-*`, `tavily`, `x-search`) take their keys from the environment or the rbw vault. Never print, store or pass a key as an argument. If the vault is locked, ask me to unlock it; do not set up another credential store, run a login or installer, or fall back to keyless access.
