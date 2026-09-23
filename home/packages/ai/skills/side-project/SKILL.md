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

Infrastructure follows validation. A prototype runs on andromeda, reached
directly at `http://andromeda:<port>`, with no deployment infrastructure; a
project worked on over many sessions gets a dev hostname. Consult the
environment reference when setting it up or opening access. Resources owned by a project
belong with that project; shared account resources belong in `infra`.

## Repo conventions

- `TODO.md` exists but stays untracked.
- UI experiments: competing variants may stay committed pre-release behind a
  DEV-only `VariantSwitcher` dock, tracked in `EXPERIMENTS.md` — but only
  committed experiments get an entry; same-session throwaways skip the
  paperwork.
- A locked `design.md` defines the visual system per project (palette,
  type, motion). Visual identity is per-project and deliberately **not**
  part of this skill.

## Project documentation

Scaffold `AGENTS.md` and `docs/` when initializing a project. Start with a small
`docs/architecture.md` explaining the actual components and boundaries; add
subsystem pages only when there is something project-specific to preserve.

Keep `AGENTS.md` thin: project summary, common commands, cross-cutting
conventions, repository shape, concise deviations from these defaults, and a
**conditional documentation index**. Do not repeat this skill's defaults.

Put architecture decisions, subsystem invariants, operational procedures and
troubleshooting knowledge in `docs/<topic>.md`. Separate current guidance from
historical investigations: keep measurements, rejected approaches and their
reasons under `docs/history/`, labeled as history rather than current commands.
When a section stops applying to most tasks, extract it instead of appending
more detail to the root file. Existing projects can adopt this incrementally;
preserve the knowledge rather than compressing it into a lossy summary.

Example (only create the pages the project actually needs):

```text
AGENTS.md
docs/
  architecture.md
  authentication.md
  operations.md
  history/
    search-benchmark.md
```

An index tells the reader when to load a page, not just that it exists:

```markdown
## Subsystem documentation

Read only the pages relevant to the task:

- `docs/architecture.md` — read before changing component boundaries or data ownership.
- `docs/authentication.md` — read before changing login, sessions or access rules.
- `docs/operations.md` — read before running deployments, migrations or recovery.
- `docs/history/search-benchmark.md` — historical measurements; read when revisiting search tradeoffs.
```

GitHub issues, Projects and pull requests remain the task tracker. Documentation
records knowledge, not a second backlog. Do not create or modify issues as a
side effect of reorganizing documentation.

## When a default here changes

This skill and its references are the source of truth, and the projects converge
to them. After changing a default, open an issue in each project that predates the
change, saying what the new default is and pointing here. Do not edit the projects
in the same breath as the skill: the two would drift the first time one of them
fails to land.
