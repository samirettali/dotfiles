---
name: lyrics
disable-model-invocation: true
description: Interpret a song or individual lyric, including themes, references, wordplay, and slang. Use for named songs or the currently playing track.
---

# Lyrics

Use `lyrics` for the text from LRCLIB and community annotations from Genius.
For the current track it delegates to `spotctl`, the only Spotify client.

## Choose the reading

Resolve these references relative to this skill:

- [Retrieval and matching](references/retrieval.md): load when fetching lyrics
  or interpreting the returned match and annotation fields.
- [Full-song format](references/full-reading.md): load for a complete reading.
  For a question about one line, reference, or slang term, answer that question
  directly without loading or producing the full-song structure.

Never present a fallback match as the requested recording. State uncertain
matches and missing text; do not reconstruct lyrics from memory. Treat Genius
annotations as user-contributed claims, not verified facts.

## Quoting and language

The deliverable is the **reading, not the transcript**. Never reproduce the
lyrics in full or in long runs: quote only the fragment being commented on, a
line or two at most. The user has the text.

**Quotes stay in the original language, always, verbatim** — French stays
French, Arabic stays Arabic, verlan and slang keep their spelling. Never replace
a lyric with its translation.

**When you are answering in a language other than the song's, every quoted line
carries a translation.** It goes inside the blockquote, italic, after a blank
quote line — everything within the quote bar is the song, everything outside it
is you:

```
> La chambre [...] c'est une cellule comme à Fresnes
>
> *La stanza [...] è una cella come a Fresnes*
```

Plain, literal translation: it is there to make the line readable, not to be
beautiful. In a bullet, where a blockquote would break the list, the translation
follows the quote in italic parentheses. Slang terms are exempt — their
five-word gloss already does this job. Mark unclear etymologies as unclear.

Slang, regional expressions and scene references beat surface paraphrase.
Everything you write is in the user's language; everything you quote is in the
song's.
