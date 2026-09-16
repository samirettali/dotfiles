# Where the signal is

Delegate the reading to an `Explore` subagent and keep only its conclusion:
the vault is large and every line read here is re-sent for the rest of the
session. Ask for under 500 words: recurring themes, and 12-15 concrete titles
or quotes that could seed a project.

## Vault

At `~/Documents/Notes`; conventions in its `AGENTS.md`, read them first.

- Root notes: his own writing. `Mindfucks.md`, `Questions that keep me up at
  night.md`, `Fun challenges.md`, `Trading ideas.md`, the puzzle and paradox
  notes, the wordplay notes (`Anagrams.md`, `Italian rhymes.md`).
- `Clippings/`: web and YouTube captures, frontmatter only, almost no notes
  of his. The `categories` wikilinks and the channels are the signal, not the
  bodies. About 200 carry a `youtubeId`.
- Categories are wikilinks in frontmatter, not files. Count them with a
  script (frontmatter `categories:` across the vault, grouped) rather than
  reading `Categories/`, which holds one Base and nothing else.
- `bases/`: `Curiosities.base`, `Most used categories.md`, `todo/` (a long
  list of YouTube channel URLs).
- `mysteries/To do.md`: a research backlog of its own.

## Linkding

Through the `linkding` skill (`linkctl`, JSON on stdout). Tags carry no counts,
so count them from a full listing:

```sh
linkctl bookmark list --limit 0 | jq -r '.results[].tag_names[]' | sort | uniq -c | sort -rn | head -40
linkctl bookmark list --tag <top-tag> --limit 100
linkctl bookmark list --unread --limit 100
```

Unread links and the YouTube ones (`jq '.results[] | select(.url | test("youtu"))'`) are
the ones he saved and never got to.

Do not mine what he has already built: check `~/dev` for existing projects and
skip anything they cover.
