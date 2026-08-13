---
name: side-project
description: The conventions of Samir's personal side projects — default stack, staged infrastructure, where infrastructure lives, repo layout and UX defaults. Use when starting one, when adding a major component (backend, frontend, public site) to an existing one, and when a project has to adopt a convention that changed here.
---

# Side project

Technical defaults for personal side projects. Every choice here is a
**default, not a law**: at setup time an alternative can be picked, but any
deviation must be recorded in that project's `AGENTS.md` with a one-line
reason. What is not deviated from does not need documenting — this file is
the implicit baseline.

## Project shape

Not every project has every part. Decide the shape first; it emerges from
what the project is:

- **Full product**: backend API + authenticated panel (+ optional public site).
- **API only**: no frontend at all.
- **Frontend only**: static site / web utils, no backend, no auth.

Only set up the parts the shape needs.

## Stack defaults

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

**Frontend** — TypeScript + React + Vite. Typed API client generated with
`openapi-typescript` + `openapi-fetch` from the same spec. `lucide-react`
for icons (never unicode glyphs as icons), `@fontsource` for fonts.
Formatting and linting with **Biome** (formatter at 120 columns, linter with
the react domain; every suppression carries a reason). Public marketing/booking
site, when one exists: **Astro with React islands**.

**Tooling** — nix devshell + Makefile as the entry point (`make generate`
regenerates oapi-codegen + sqlc + TS clients), `air` for backend live
reload, `direnv` with an untracked `.envrc` for environment, `pnpm`.

**Testing** — Go table tests at the application layer with stubbed ports;
domain logic tested pure. No frontend test framework by default: typecheck,
lint, and live browser verification carry the frontend.

**Auth** — only if the product has users, and **not at the start**. See the
prototype stage below. When real auth arrives: ZITADEL (OIDC + PKCE), with
the client app managed declaratively in OpenTofu (`infra/<env>/`), redirect
URIs included.

## Environments

Infrastructure follows validation, not the other way around. Most side projects
die young; don't pay for infra they will never need.

1. **Prototype** — run directly on the dev host (andromeda), reach it over an
   SSH port-forward. No proxy, no secrets management, no OpenTofu, no deploy.
   `localhost` is a secure context, so anything needing `crypto.subtle` works
   through the forward.
   **Auth is stubbed**: the current-user lookup lives in exactly one seam
   (verifier/middleware) and an env-gated mode (`AUTH_MODE=stub`) resolves a
   fixed seeded user. The server must **refuse to start** in stub mode outside
   dev environments. Multi-user flows cannot be validated this way — if
   multi-user *is* the product, bring real auth forward.
2. **Dev** — a tailnet-only HTTPS hostname through the shared proxy in
   `servers/side-proxy`, and a real identity provider managed in `infra/dev/`.
3. **Staging** — **only when it needs its own data.** Payments to exercise with
   test cards, a migration to rehearse, a demo that must not touch real records.
   Separate database, migrations applied by a `migrate` service on deploy,
   separate `infra/staging/`. It is not a rung everything climbs: plenty of
   projects go from dev to prod, and adding a staging is adding a second
   database and a second set of credentials to keep alive.
4. **Prod** — when the project stands on its own.

## Letting people in

Decide by what is being protected, not by which environment it is.

- **Only me** — the tailnet is the boundary. No authentication at all.
- **A few named people, revocably** — Cloudflare Access with the account's
  One-time PIN provider: they get a code by email, and access is withdrawn by
  removing the address. Use it when knowing *who* came in matters, which for a
  side project usually means showing it to a business.
- **Whoever holds the link** — `basic_auth` in the shared dev proxy, one
  password per project kept in the vault, plus an access log for that hostname:
  reading leaves no other trace. There is no shared-password login in Cloudflare
  Access; a Worker could render one, at the price of code at the edge.
- **A public site with one expensive action** — do not wall the site.
  A model call that spends credits is an authorization problem on that endpoint,
  not a reason to lock out readers of content that is not secret. Wrapping the
  whole thing in a password is the shortcut taken when there is no time to write
  the check, and it is worth undoing once the project has any notion of a user.

## Hostnames

Buy the product's domain when an audience appears, not when an environment does.

Dev stays on the personal domain for good — it is tailnet-only and nobody else
sees it: `<project>-dev.samirettali.com`. Previews stay there too, they are
throwaway by nature. Once there is a domain, staging is a subdomain of it and
prod is the apex, so what a visitor reads matches the product rather than its
author.

Moving later costs more than a DNS record, in two specific ways. OIDC redirect
URIs, cookies and Access applications are all per-hostname, so a late move means
redoing the identity configuration on both sides. And the dev proxy's Cloudflare
token carries `DNS:Edit` on `samirettali.com` alone: a new zone needs it widened
or a second token, and the symptom is a certificate that never issues.

## Where infrastructure lives

Split by ownership, not by convenience. Anything that is born and dies with the
project — its ZITADEL apps, the DNS records of its hostnames, its tunnels and
Access applications — lives in the project's own repo, applied by its own CI,
with its own state bucket so the whole thing can be handed over. Anything that
belongs to the account and is shared — GitHub repository settings, Actions
secrets, the bucket the states themselves live in — lives in `infra`.

The reason is blast radius, not tidiness: if a project's infrastructure lived in
the shared repo, that project's CI would need credentials to the shared state,
and one leaked token in one side project would reach every repository setting
you have.

A project too small to have an environment does not need an `infra/` directory:
its single DNS record can sit in `infra` and move out with an `import` block the
day it grows.

## When a default here changes

This file is the source of truth, and the projects converge to it. After changing
a default, open an issue in each project that predates the change, saying what
the new default is and pointing here — an agent picking that issue up reads this
skill and adapts the project. Do not edit the projects in the same breath as the
skill: the two would drift the first time one of them fails to land.

## Repo conventions

- `AGENTS.md` is the single source of persistent project knowledge (shared
  across Claude Code, pi, codex — never tool-private memory). Deviations
  from this skill's defaults live there. Long or occasional material goes in
  linked files (`design.md`, `EXPERIMENTS.md`, …) with one-line pointers.
- Conventional commits, **one commit per logical change**. No sign-offs.
- `TODO.md` exists but stays untracked.
- UI experiments: competing variants may stay committed pre-release behind a
  DEV-only `VariantSwitcher` dock, tracked in `EXPERIMENTS.md` — but only
  committed experiments get an entry; same-session throwaways skip the
  paperwork.
- A locked `design.md` defines the visual system per project (palette,
  type, motion). Visual identity is per-project and deliberately **not**
  part of this skill.

## UX defaults

Behavioural choices that survived real usage; visual style stays out.

- **Never stack popups.** Sub-flows are in-popup steps; a confirm dialog is
  the only legitimate overlay. Escape goes back one level, outside click
  closes (guarded by a discard confirmation when the form is dirty).
- **Never animate layout.** Layout snaps to its final size immediately —
  content laid out and painted once, full from the first frame; motion is a
  compositor-driven reveal (clip-path/transform/opacity). Animating `height`
  re-layouts every frame and some engines defer painting freshly-mounted
  content until it ends.
- **No dead ends in filters.** Offer only options that lead to results;
  already-selected options stay visible so they can be deselected.
- **Content before it's needed.** Prefetch and cache (module-level, TTL,
  invalidated by mutations) so a flow opens already populated instead of
  loading in front of the user; recover visibly from failed fetches with a
  retry affordance.
- **Never land on emptiness.** Preselect the first option that has results
  (first free day, first non-empty section) before first paint.
- **Reserved areas.** Zones whose content loads or empties keep a fixed
  size; loading and empty states never move the layout.
- **Forms submit only when valid.** Submit stays disabled until required
  inputs validate; every button carries an explicit `type`.
- **Deep-linkable state.** Sections and presets ride query parameters;
  one-shot presets are consumed and then removed from the URL.
- **Switch vs checkbox.** A toggle switch for persistent on/off state that
  takes effect immediately; a checkbox for choices submitted with a form.
