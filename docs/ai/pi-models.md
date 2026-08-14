# pi model configuration

Read this before changing `pi-models` or pi's model registry.

`home/packages/ai/pi-coding-agent/models.json` is the single source of truth.
`default.nix` reads it with `fromJSON` and renders two deployed files:

- `enabledModels` becomes `~/.pi/agent/settings.json`.
- `providers` becomes `~/.pi/agent/models.json`.

Both deployed files are store symlinks.
Edit the repository file and run `make build`; never edit the deployed copies.

## Editor

`pi-models` lives in `home/packages/shell/scripts/pi-models/`.
It starts a Node server on a random local port and serves one `app.html` file.
Saving changes only the repository file.
Applying the result still requires `make build`.

## Provider limits

`pi-models --sync`, exposed as `make models`, fetches endpoints for each model that pins a provider.
It rewrites only changed limits and prints a diff.

Pinned `contextWindow` and `maxTokens` values are snapshots.
Neither pi nor OpenRouter refreshes them automatically.
If a pinned provider disappears, synchronization reports it and leaves the model unchanged.
It must not silently select another provider.

Fetch limits from each model's `endpoints` response, not `/api/v1/models`.
The latter's `top_provider` describes OpenRouter's current preferred provider, not a pinned provider.

An endpoint tag includes provider and quantization, such as `novita/fp8`.
A bare routing entry such as `only: ["novita"]` accepts every quantization from that provider.

## Built-in models

A custom entry in `models[]` with the same ID replaces pi's built-in entry.
Replacement drops built-in pricing and metadata.

Use `modelOverrides` for providers present in `~/.pi/agent/models-store.json`.
Use `models[]` only for genuinely custom providers such as LM Studio.
