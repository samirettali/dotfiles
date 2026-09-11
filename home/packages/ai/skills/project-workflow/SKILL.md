---
name: project-workflow
description: Work on tasks tracked as GitHub issues in Samir's personal repos — pick up an issue, open a new one, close it with a PR. Use when asked to work on an issue or a task, to open an issue for something found along the way, or to check what is pending on a project.
---

# Project workflow

Tasks for personal projects are **GitHub issues**, collected in the `dev` Project
(<https://github.com/users/samirettali/projects/1>). Repos live under
`samirettali/`, local checkouts in `~/dev/<repo-name>`.

Read the reference for the operation, relative to this skill:

| Work | Read |
| --- | --- |
| Starting on an issue | [Pick up](references/pickup.md) |
| Filing something found along the way | [Open](references/open.md) |
| Opening the PR and handing over | [Close](references/close.md) |

## Statuses

`Priority` (P0–P3) and `Status` are **Project fields**, not labels. **Never
decide `Priority` on your own**: Samir does the triage. If he tells you what it
should be, set it.

`📋 Backlog` → `🏗 In progress` → `👀 In review` → `✅ Done`

Backlog and Done are automatic (Project workflows: *item added* and *pull request
merged* / *item closed*). The two middle transitions are yours to make:

```sh
gh project item-edit 1 --owner samirettali \
  --url https://github.com/samirettali/<repo>/issues/<N> \
  --field Status --value "🏗 In progress"
```

The value is the option's **exact name, emoji included**: `"In progress"` is
rejected, and the error lists every valid option. `--owner` selects the
*Project*, not the repo: the issue is named by its URL and may live under a
different owner. Verified on gh 2.97.
