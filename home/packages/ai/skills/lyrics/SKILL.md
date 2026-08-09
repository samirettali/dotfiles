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
`fragment` it comments and the annotation text, sorted by votes. Where the
references, slang, place names, in-scene allusions and factual context live —
none of it reconstructable from the bare text.

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

The deliverable is the **reading, not the transcript**. What the song is about,
its themes, structure and register; the references, wordplay and double meanings
unpacked; the context a listener would miss. Quote only the lines you actually
comment on. Never reproduce the lyrics in full or in long runs — the user wants
the interpretation and has the text in front of them.

The catalogue is mostly Italian and French rap, much of it underground, often
multilingual within one verse. Slang, regional expressions and scene references
matter more than surface paraphrase. Answer in the user's language.
