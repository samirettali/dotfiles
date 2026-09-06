# Lyrics retrieval and matching

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

Two defaults keep the payload small:

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

## When more exist than you were given

**`annotations.truncated: true` means there are more**; `annotations.count` is
the total. Never infer this from the items you can see — a song with exactly
fifteen annotations is not truncated, and `truncated` is the only honest signal.

When set, retrieve additional annotations if the requested analysis needs them,
for example when a question names a line omitted from the initial payload.
`--max-annotations 0` returns them from the cache, no `--refresh` needed — every
annotation is stored and the limit only trims the output. Keep the answer scoped
to the request rather than expanding it to cover everything fetched. Otherwise,
answer from the default set, mention how many more exist, and offer a deeper
reading. Ask before expanding the deliverable, not before relevant cached retrieval.
