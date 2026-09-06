# Infrastructure and access

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
- **A few named people, and the product already has an identity provider** —
  use *that* one, and keep a list of accounts in an env var. sottotesto is the
  worked example: it talks to Spotify anyway, so the login is Spotify and the
  allowlist is Spotify account emails, checked per request so that removing an
  address takes effect at the next click. Cheaper than Cloudflare Access and
  than ZITADEL, and it avoids asking one person for two logins.
- **Whoever holds the link** — `basic_auth` in the shared proxy, one password
  per project kept in the vault, plus an access log for that hostname: reading
  leaves no other trace. There is no shared-password login in Cloudflare Access;
  a Worker could render one, at the price of code at the edge. **The weakest
  option**, and the one to leave behind first: a password has to be sent to each
  person by hand, it says nothing about who came in, and it cannot be revoked for
  one of them.
- **A public site with one expensive action** — do not wall the site.
  A model call that spends credits is an authorization problem on that endpoint,
  not a reason to lock out readers of content that is not secret. Wrapping the
  whole thing in a password is the shortcut taken when there is no time to write
  the check, and it is worth undoing once the project has any notion of a user.
  sottotesto did exactly that, in the direction of the tier above.

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
