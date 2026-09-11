---
name: ideas
disable-model-invocation: true
description: Mine Samir's Obsidian vault and linkding bookmarks for side-project ideas, propose them in batches of ten, and turn the ones he picks into self-contained prompts another agent can run unattended. Invoked by hand when there is spare usage or a free evening; never on its own.
---

# Ideas

Samir has more saved than he has built: a thousand vault notes, hundreds of
YouTube clippings, a linkding full of links. This skill turns that backlog into
proposals, then into prompts that an agent on `andromeda` can run without him.

Three steps, and the loop between the last two runs until he says stop. Read
the reference for the step, relative to this skill:

| Step | Read |
| --- | --- |
| 1. Mine the vault and linkding | [Sources](references/sources.md) |
| 3. Write the prompt for a pick | [Prompt](references/prompt.md) |

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
