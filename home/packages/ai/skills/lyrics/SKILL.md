---
name: lyrics
description: Read and interpret the lyrics of a song — what it is about, its themes, the references and quotations it makes, its wordplay and slang. Fetches the text from LRCLIB and the community annotations from Genius with the `lyrics` command. Use when asked what a song means, what it talks about, what a line refers to, who or what it name-drops, or to explain the current track. Triggers on "cosa significa questa canzone", "di cosa parla", "quali citazioni", "spiegami il testo", "what does this song mean", song meaning, lyrics analysis, bars, punchlines, references.
---

# Lyrics

`lyrics` fetches a song's text and its community annotations so you can explain
the song. It never talks to Spotify itself: for the current track it shells out
to `spotctl`, which stays the only Spotify client.

```sh
lyrics --now                                  # the track playing right now
lyrics "Caparezza" "Limiti"                   # by artist and title
lyrics "Nekfeu" "Vinyle" --album "Cyborg" --duration 245
lyrics "IAM" "Petit frère" --no-annotations   # skip Genius
lyrics --now --max-annotations 0              # every annotation, not the top 15
lyrics --now --synced                         # add the timestamped text
lyrics --now --refresh                        # ignore the cache
```

Output is JSON on stdout. Results are cached in `~/.cache/lyrics/lyrics.db`
forever, because lyrics do not change; `--refresh` re-fetches.

Two defaults keep the answer small, since the whole payload has to be read
before a word of it is useful. Only the plain text is returned — `--synced` adds
the timestamped copy, which is the same words with `[mm:ss.xx]` in front and is
worth asking for only to follow along with playback. And annotations stop at the
15 best-voted; see below.

## Read `match.exactness` before you answer

This is the field that matters. The lyrics you got back may not be the lyrics of
the exact recording that was asked about:

| value | meaning |
| --- | --- |
| `exact` | artist, title, album and duration all matched |
| `no-album` | matched on artist, title and duration |
| `loose-duration` | duration was not verified — could be another version |
| `normalized` | matched after stripping a suffix like `- Remastered` |
| `original-of-remix` | **the text is the original's, not the remix's** |
| `fuzzy` | matched through search; `match.note` says how confident |
| `not_found` | nothing found; `match.tried` lists the steps attempted |

Anything other than `exact` or `no-album` must be **stated to the user in one
short sentence** before the analysis. `original-of-remix` especially: a remix
usually carries the original vocal, but a freestyle over the same beat is a
completely different text, and no API can tell them apart. Never present a
fallback match as if it were the song asked about.

On `not_found`, say so plainly. Do not reconstruct lyrics from memory and do not
guess — a confidently wrong reading of a song is worse than no reading. The
gaps are concentrated in cyphers, freestyles, live sessions and very small
artists, which is worth mentioning as the likely reason.

## Annotations are the good part

`annotations.items` holds Genius's crowd-sourced annotations, each with the
`fragment` it comments and the annotation text, sorted by votes. These are where
references, slang, place names, in-scene allusions and factual context actually
live — the things nobody can reconstruct from the bare text.

Roughly 71% of tracks have at least one and 55% have three or more, so treat
their absence as normal, not as a failure. `annotations.available: false` carries
a `reason`; the token lives in sops as `genius_access_token`, and if it was
rejected it can be regenerated at genius.com/api-clients.

Annotations are user-contributed and occasionally wrong or joking. Where one
makes a strong factual claim worth relying on, say it comes from Genius rather
than asserting it yourself.

### When there are more than you were given

Only the 15 best-voted come back by default. **`annotations.truncated: true`
means there are more**, and `annotations.count` says how many in total. Do not
infer this from the number of items you can see: a song with exactly fifteen
annotations is not truncated, and `truncated` is the only honest signal.

When it is set, answer with what you have and close by offering the rest — "ci
sono altre N annotazioni, vuoi che approfondisca?" — rather than fetching them
unasked. Getting them is `--max-annotations 0`, which is served from the cache
and needs no `--refresh`: every annotation is stored, the limit only trims the
output.

## Answering

The deliverable is the **reading, not the transcript**. Explain what the song is
about, its themes, structure and register; unpack the references, wordplay and
double meanings; give the context a listener would miss. Quote only the
individual lines you are actually commenting on, and never reproduce the lyrics
in full or in long runs — the user wants the interpretation, and has the text in
front of them anyway.

The catalogue this is used on is mostly Italian and French rap, much of it
underground, and often multilingual within a single verse. Slang, regional
expressions and scene references matter more than surface paraphrase. Answer in
the language the user used.
