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

Through the `linkding` skill (`linkctl`, JSON on stdout). The collections have
separate purposes:

- **Unarchived** is the read/watch-later queue, whether `unread` is true or false.
- **Archived** holds functional resources: tools, documentation and sites he
  returns to. It is not a collection of finished reading or a backlog to clear.
- **`Clippings/`** holds material worth rereading or rewatching. Keep that durable
  collection separate from both the queue and the functional archive.

The default listing is unarchived; `--unread` narrows it and misses part of the
queue. Tags carry no counts, so count them from a full queue listing:

```sh
linkctl bookmark list --limit 0 | jq -r '.results[].tag_names[]' | sort | uniq -c | sort -rn | head -40
linkctl bookmark list --tag <top-tag> --limit 100
linkctl bookmark list --limit 100
```

YouTube links (`jq '.results[] | select(.url | test("youtu"))'`) identify the
medium, not whether he has watched them. Do not infer reading history from that
or from `unread` alone. A functional resource found in the queue is misfiled:
propose archiving it, not deleting it. This discovery step changes no bookmarks.

Do not mine what he has already built: check `~/dev` for existing projects and
skip anything they cover.
