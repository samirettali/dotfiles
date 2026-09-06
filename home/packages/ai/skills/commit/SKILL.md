---
name: commit
description: "Read this skill before making git commits"
---

Create a git commit for the current changes using a concise Conventional Commits-style subject.

## Format

`<type>(<scope>): <summary>`

- `type` REQUIRED. Use `feat` for new features, `fix` for bug fixes. Other common types: `docs`, `refactor`, `chore`, `test`, `perf`.
- `scope` OPTIONAL. Short noun in parentheses for the affected area (e.g., `api`, `parser`, `ui`).
- `summary` REQUIRED. Short, imperative, <= 72 chars, no trailing period.

## Notes

- Body is OPTIONAL. When there is one, it says *why*: the motivation, why this solution, and the alternatives you rejected. Never restate the diff. Wrap it at 72 columns, because `git log` indents by four.
- If the work has an issue or a ticket, reference it the way the repository already does.
- Commit with an explicit pathspec (`git commit -m … -- <paths>`), so that files staged for another reason do not ride along.
- Mark a breaking change with a `!` before the colon: `feat!:`, or `feat(api)!:`. Do NOT add footers, `BREAKING CHANGE:` included.
- Do NOT add sign-offs (no `Signed-off-by`).
- Only commit; do NOT push.
- If it is unclear whether a file should be included, ask the user which files to commit.
- Treat any caller-provided arguments as additional commit guidance. Common patterns:
  - Freeform instructions should influence scope, summary, and body.
  - File paths or globs should limit which files to commit. If files are specified, only stage/commit those unless the user explicitly asks otherwise.
  - If arguments combine files and instructions, honor both.

## Scope

Inspect the intended diff and staging state before committing. Include only the
requested changes, preserving unrelated work even when no paths were supplied.
Follow the repository's documented conventions; consult recent commit subjects
only when the convention is unclear. Commit with an explicit pathspec.
