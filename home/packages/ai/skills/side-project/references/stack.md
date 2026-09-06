# Stack defaults

## Backend and data

**Backend** — Go. Hexagonal layout (`domain` / `application` / `adapters` /
`ports` / `di`): pure domain logic testable without a database, application
services own transactions, adapters at the edges. OpenAPI-first: the spec
(`api/openapi.yaml`) is the source of truth, `oapi-codegen` generates the
server interfaces. Health endpoints (liveness/readiness) from day one.
Patterns to reach for when the need appears (not scaffolded by default):
transactional outbox for events/emails with backoff retries, idempotency
keys on public writes.

**Data** — PostgreSQL. `sqlc` for typed data access (hand-written SQL in
`queries/`), `pgx` pool, **goose** migrations in `migrations/` as the only
way schema changes — never hand-edit a tracked database, write a migration
(`make migrate-create / migrate-up / migrate-down / migrate-redo`).

## Frontend and tooling

**Frontend** — TypeScript + React + Vite. Typed API client generated with
`openapi-typescript` + `openapi-fetch` from the same spec. `lucide-react`
for icons (never unicode glyphs as icons), `@fontsource` for fonts.
Formatting and linting with **Biome** (formatter at 120 columns, linter with
the react domain; every suppression carries a reason). Public marketing/booking
site, when one exists: **Astro with React islands**.

**Tooling** — nix devshell + Makefile as the entry point (`make generate`
regenerates oapi-codegen + sqlc + TS clients), `air` for backend live
reload, `direnv`, `pnpm`.

## Session configuration

**The `.envrc` is committed, and there is no `.envrc.example`.** It holds no
secret: every one is read from rbw at call time, `$(rbw get <entry>)`, so the
file is configuration and belongs in the repo like any other. An example file is
a second copy of the same thing that drifts from the first, and it makes every
checkout start with a copy step for values that are not secret anyway.

Two things that decide what may go in it:

- **A value that grants nothing is not automatically publishable.** Other
  people's data — an allowlist of email addresses, say — is theirs, and git
  history outlives any edit. Either keep it in the vault, or accept it knowing
  that making the repo public takes the history with it.
- **rbw needs an unlocked agent, sops does not.** sops-nix decrypts at profile
  activation and leaves files on disk, so a long-lived service can start
  unattended after a reboot. Prefer sops when something must come back up on its
  own; rbw is right for anything you launch in a session you are sitting in.

**Guard every `rbw` call in a `.envrc`, or entering the directory will hang.**
With the agent locked, `rbw get` asks pinentry for the password, and direnv gives
pinentry no terminal to ask on — so it waits rather than failing, and the shell
stops on `cd` with a message about direnv being slow and nothing about the vault.
Check first, warn, and leave the variables unset so the program refuses to start
and says which ones are missing:

```sh
vault() {
  if rbw unlocked >/dev/null 2>&1; then
    rbw get "$1"
  fi
}

if ! rbw unlocked >/dev/null 2>&1; then
  echo "rbw is locked: run 'rbw unlock' outside this directory, then 'direnv reload'" >&2
fi

export SOME_TOKEN="$(vault some-entry)"
```

The check costs about 18ms when the vault is locked. It is the difference between
a message and a hang.

## Testing and auth

**Testing** — Go table tests at the application layer with stubbed ports;
domain logic tested pure. No frontend test framework by default: typecheck,
lint, and live browser verification carry the frontend.

**Auth** — only if the product has users, and **not at the start**. See the
[prototype stage](infrastructure.md#environments). When real auth arrives:
ZITADEL (OIDC + PKCE), with the client app managed declaratively in OpenTofu
(`infra/<env>/`), redirect URIs included.
