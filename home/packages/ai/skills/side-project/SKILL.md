---
name: side-project
description: The conventions of Samir's personal side projects — default stack, staged infrastructure, where infrastructure lives, repo layout and UX defaults. Use when starting one, when adding a major component (backend, frontend, public site) to an existing one, and when a project has to adopt a convention that changed here.
---

# Side project

Technical defaults for personal side projects. Every choice here is a
**default, not a law**: at setup time an alternative can be picked, but any
deviation must be recorded in that project's `AGENTS.md` with a one-line
reason. What is not deviated from does not need documenting — this skill is
the implicit baseline.

## Project shape and relevant guidance

Only set up the parts the project needs:

- **Full product**: backend API + authenticated panel (+ optional public site).
- **API only**: no frontend at all.
- **Frontend only**: static site / web utils, no backend, no auth.

Load references by the part being added or changed, not all at once. Paths are
relative to this skill:

| Work | Read |
| --- | --- |
| Backend, data, frontend, tooling, `.envrc`, or testing setup | [Stack defaults](references/stack.md) |
| Environments, authentication/access, hostnames, or infrastructure | [Infrastructure and access](references/infrastructure.md) |
| Interface behavior | [UX defaults](references/ux.md) |

Infrastructure follows validation. A prototype runs on andromeda through an
SSH port-forward, with no deployment infrastructure; consult the environment
reference when setting it up or opening access. Resources owned by a project
belong with that project; shared account resources belong in `infra`.

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

## When a default here changes

This skill and its references are the source of truth, and the projects converge
to them. After changing a default, open an issue in each project that predates the
change, saying what the new default is and pointing here. Do not edit the projects
in the same breath as the skill: the two would drift the first time one of them
fails to land.
