---
name: ideas
disable-model-invocation: true
description: Mine Samir's Obsidian vault and linkding bookmarks for side-project ideas, propose them in batches of ten, and turn the ones he picks into self-contained prompts another agent can run unattended. Invoked by hand when there is spare usage or a free evening; never on its own.
---

# Ideas

Samir has more saved than he has built: a thousand vault notes, hundreds of
YouTube clippings, a linkding full of links. This skill turns that backlog into
proposals, then into prompts that an agent on `andromeda` can run without him.

Three steps, and the loop between the last two runs until he says stop.

## 1. Mine

Delegate the reading to an `Explore` subagent and keep only its conclusion:
the vault is large and every line read here is re-sent for the rest of the
session. Ask for under 500 words: recurring themes, and 12-15 concrete titles
or quotes that could seed a project.

**Vault** at `~/Documents/Notes` (conventions in its `AGENTS.md`, read them
first). Where the signal is:

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

**Linkding** through the `linkding` skill. Tags carry no counts, so count them
from a full listing:

```sh
linkding list --json --limit 5000 | jq -r '.[].tag_names[]' | sort | uniq -c | sort -rn | head -40
linkding list --tag <top-tag> --limit 100
linkding list --unread --limit 100
```

Unread links and the YouTube ones (`jq 'select(.url | test("youtu"))'`) are
the ones he saved and never got to.

Do not mine what he has already built: check `~/dev` for existing projects and
skip anything they cover.

## 2. Propose

Ten at a time, numbered, one line each: a name, what it is in a sentence, and
the note or link it came from. Close with the two or three you would pick and
why, then ask which he wants.

What lands with him:

- Curious over useful. A price tracker or a feed reader is a no; a generator,
  a simulator, an algorithm taken apart and shown stage by stage is a yes.
- One idea per project, finished in a session or a day. Every idea should
  end with something to look at in a browser or run from a shell.
- Data over code: styles, rules, worlds and decks as JSON, seeded and
  deterministic, deep-linkable. This is the sottofondo model and he reaches
  for it every time.
- His domains are fair game: crypto and EVM internals, Go, the Italian
  language, films, music, chess, freestyle rap.
- Every batch after the first goes in a different direction from the last
  one; if he says "other ideas", the next ten are not variations of the
  previous ten.

The `sotto*` names are a running joke, not a rule. Suggest one when it is
good; otherwise say the agent picks a short Italian name and records why.

## 3. Write the prompt

For each pick, one Markdown file in `~/dev/prompts/<name>.md`, in English,
self-contained: he pastes it into an agent on another machine that has none
of this conversation. Shape it like the ones already there, and like this:

1. **What to build**, in two sentences, and the name or how to choose one.
2. **Load the `side-project` skill** and say which shape applies: frontend
   only, API only, full product. Repo at `~/dev/<name>`, `git init`,
   Conventional Commits, one commit per logical change, `AGENTS.md` for the
   decisions the code alone would not reveal, a locked `design.md` when there
   is a UI.
3. **The principles** that make it his: data not code, deterministic from a
   seed with `Math.random` banned outside one file, nothing from wall-clock
   time, state in the URL.
4. **The substance**: stages, families, presets, components, whatever the
   project is made of, in enough detail that the agent does not have to
   guess and specific enough to verify (the glider must glide, the file must
   open in a real viewer). Name the papers and reference implementations
   and ask for every constant to carry its source.
5. **Interface**: Italian UI copy, English code and docs, the skill's UX
   defaults, light and dark, the dev server on `0.0.0.0` with `andromeda` in
   Vite's `server.allowedHosts` so it is reachable at `http://andromeda:<port>`
   from the tailnet, port in the Makefile and in `AGENTS.md`.
6. **How to work**: no questions unless two readings lead to materially
   different work, build the thin end-to-end path first and deepen after,
   verify in a real browser at each step, screenshots in `docs/`, `TODO.md`
   untracked, and what to print when done.

Keep it under 80 lines. Do not run the prompt yourself and do not create the
repo: the file is the deliverable. Say where it landed in one line.
