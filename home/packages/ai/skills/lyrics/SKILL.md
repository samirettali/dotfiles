---
name: lyrics
description: Read and interpret the lyrics of a song — what it is about, its themes, the references and quotations it makes, its wordplay and slang. Fetches the text from LRCLIB and the community annotations from Genius with the `lyrics` command. Use when asked what a song means, what it talks about, what a line refers to, who or what it name-drops, or to explain the current track. Triggers on "cosa significa questa canzone", "di cosa parla", "quali citazioni", "spiegami il testo", "what does this song mean", song meaning, lyrics analysis, bars, punchlines, references.
---

# Lyrics

`lyrics` fetches a song's text and its community annotations. Never talks to
Spotify itself: for the current track it shells out to `spotctl`, which stays the
only Spotify client.

```sh
lyrics --now                                  # the track playing right now
lyrics "Caparezza" "Limiti"                   # by artist and title
lyrics "Nekfeu" "Vinyle" --album "Cyborg" --duration 245
lyrics "IAM" "Petit frère" --no-annotations   # skip Genius
lyrics --now --max-annotations 0              # every annotation, not the top 15
lyrics --now --synced                         # add the timestamped text
lyrics --now --refresh                        # ignore the cache
```

JSON on stdout. Cached forever in `~/.cache/lyrics/lyrics.db`, since lyrics do
not change; `--refresh` re-fetches.

Two defaults keep the payload small — all of it must be read before any of it is
useful:

- Plain text only. `--synced` adds the timestamped copy: same words, `[mm:ss.xx]`
  in front. Worth it only to follow along with playback.
- Annotations stop at the 15 best-voted. See below.

## Read `match.exactness` first

The text you got may not belong to the recording asked about:

| value | meaning |
| --- | --- |
| `exact` | artist, title, album and duration all matched |
| `no-album` | matched on artist, title and duration |
| `loose-duration` | duration was not verified — could be another version |
| `normalized` | matched after stripping a suffix like `- Remastered` |
| `original-of-remix` | **the text is the original's, not the remix's** |
| `fuzzy` | matched through search; `match.note` says how confident |
| `not_found` | nothing found; `match.tried` lists the steps attempted |

Anything but `exact` or `no-album`: **state it in one short sentence before the
analysis**. `original-of-remix` especially — a remix usually carries the original
vocal, but a freestyle over the same beat is a completely different text, and no
API tells them apart. Never present a fallback match as the song asked about.

On `not_found`, say so plainly. Do not reconstruct lyrics from memory, do not
guess: a confidently wrong reading is worse than none. Gaps concentrate in
cyphers, freestyles, live sessions and very small artists — worth naming as the
likely reason.

## Annotations are the good part

`annotations.items`: Genius's crowd-sourced annotations, each carrying the
`fragment` it comments, the annotation text, its `votes` and its `position`.
Where the references, slang, place names, in-scene allusions and factual context
live — none of it reconstructable from the bare text.

**Sorted by `votes` descending, which is not the order of the song.** `position`
is: it is where Genius places the fragment in the text. Rank by `votes` when
deciding what matters, read by `position` when writing the answer.

~71% of tracks carry at least one, 55% carry three or more. Absence is normal,
not failure. `annotations.available: false` carries a `reason`; the token lives
in sops as `genius_access_token` and can be regenerated at
genius.com/api-clients if rejected.

Annotations are user-contributed, occasionally wrong or joking. Attribute any
strong factual claim to Genius instead of asserting it yourself.

### When more exist than you were given

**`annotations.truncated: true` means there are more**; `annotations.count` is
the total. Never infer this from the items you can see — a song with exactly
fifteen annotations is not truncated, and `truncated` is the only honest signal.

When set: answer with what you have, then say how many more there are and ask
whether to go deeper. Do not fetch them unasked. `--max-annotations 0` returns
them from the cache, no `--refresh` needed — every annotation is stored and the
limit only trims the output.

## Answering

The deliverable is the **reading, not the transcript**. Never reproduce the
lyrics in full or in long runs: quote only the fragment being commented on, a
line or two at most. The user has the text.

**Quotes stay in the original language, always, verbatim** — French stays
French, Arabic stays Arabic, verlan and slang keep their spelling. Never
translate a quoted line, not even in passing, and never quote a translation as
if it were the lyric. Saying what a line means is the job; replacing its words
is not.

**Always the same shape**, in this order, so two songs read as the same kind of
answer:

1. **Opening** — two or three lines of prose: what the song is, who is speaking,
   what it is doing. The only part that is not a list.
2. **What it is about** — one bullet per theme. **Every bullet carries at least
   one quoted fragment**, italic between guillemets, as its evidence: a theme
   asserted without a line to stand on is the most generic thing you can write,
   and this is the section read first.
3. **Line by line** — the body of the answer and the longest part. **Sort the
   items by `position` ascending before writing anything**: the payload arrives
   ordered by `votes`, so writing in the order you received them opens the
   reading on a line from the middle of the song. Not a list: each fragment is a
   blockquote, its explanation the paragraph right under it.

   ```
   > Les cabas ils sont trop lourds

   The trip back to the bled with suitcases full of presents: the weight is
   the obligation to the family that stayed.
   ```

   A bullet would run the quote and the gloss together and leave no visible
   line between the song's words and yours. The blockquote is that line.
4. **References** — everything the song points at from outside itself, in two
   groups under one heading, each group only if it has entries:
   - **Works** — other tracks (samples, interpolations, quoted bars, artists
     name-dropped), films, TV series, books, games. Name the work, then what the
     line does with it: homage, dig, ironic reuse.
   - **Names** — the places, institutions, people and events the scene treats as
     shared knowledge and an outsider would not catch: a prison, a police unit,
     a neighbourhood, a nickname for a city. One line of gloss each, no more.

   The two are different jobs — one is intertextuality, the other is a
   glossary — and merging them silently makes the section look padded.
5. **How it is written** — one bullet per device: wordplay, double meanings,
   multisyllabic and internal rhymes, how a phrase is cut across the beat,
   register shifts, code-switching. Name the technique and show it in the line
   that uses it.

Bullets in sections 2, 4 and 5: they make the separation between things visible
at a glance, which prose does not. Blockquotes in section 3, for the same reason
one level down. Inside a bullet, where a blockquote would break the list, a
quoted fragment goes in italics between guillemets — *« comme ça »* — so the
song's words are still never flush against yours.

**Sections 4 and 5 only when the song has that material.** No empty heading, no
"there are no references here". Judge from the text and the annotations, not
from expectation. Both are usually present here — Italian and French rap, mostly
underground, dense in references, and built on craft: rhyme schemes, assonance
across several syllables, a punchline set up two bars earlier. Absence is a
conclusion, never a skip.

**Use every annotation you were given**, every time. They are the part nobody
can reconstruct; dropping a few is what makes one answer thinner than the next.
Merge duplicates. Where an
annotation only confirms the line, spend half a line rather than cutting it. An
annotation about a reference or a technique goes in its own section too, not
only in the line-by-line.

Slang, regional expressions and scene references beat surface paraphrase.
Everything you write is in the user's language; everything you quote is in the
song's.
