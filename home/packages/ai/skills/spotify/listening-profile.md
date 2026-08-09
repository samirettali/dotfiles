## Samir's listening profile

Derived from his full listening data and playlist library. Treat it as a
durable starting point — current top-item and recent-history data win when
they disagree.

### Taste

- Two pillars carry equal weight: rap and dark electronic music. Neither
  is "the" main genre; he moves between them constantly.
- The electronic side is dark, high-energy, and emotionally melodic: hard
  techno, rave, acid, trance, hardcore, makina, breakbeat, and cinematic
  club music. Anchors: Funk Tribu, 240 KM/H, DJ HEARTSTRING, Indecorum,
  Montee, Bad Boombox, Brutalismus 3000, The Prodigy, Underworld, Daft
  Punk — plus the Blade, Matrix, John Wick, and videogame-soundtrack
  aesthetic his playlist names cite. The mellow counterweight is melodic
  downtempo electronica, where The Blaze is an outright favorite (Kid
  Francescoli, Stavroz, and Cubicolor nearby).
- The rap side is organized by scene. Italian lyrical and conscious rap
  is the deepest vein: Caparezza above all (all-time #1 artist, dedicated
  playlist), then Murubutu, Claver Gold, Mezzosangue, Mistaman, Ghemon,
  and Cranio Randagio — alongside Italian trap and street rap (Shiva,
  Baby Gang, Simba La Rue, Rhove, Guè, Luchè). French rap is a long-term
  anchor (Alpha Wann, Hugo TSR, Nekfeu, Dinos, Freeze Corleone, IAM,
  Fonky Family).
- Classical stands as a pillar of its own, not a garnish: "Classical
  Music bangers" is one of his largest playlists, backed by orchestral,
  concerto, piano, and ambient listening (Einaudi, Satie, film scores).
- Nu/alt metal recurs in rotation (System Of A Down, Metallica, Slipknot,
  Linkin Park), and melancholy cuts across everything: trip-hop, emo rap
  (Lil Peep), Apparat, Portishead, Massive Attack, Moby.
- Taste runs deep underground. Filed tracks average ~44 Spotify
  popularity, and the core scenes sit far lower (Italian lyrical rap
  about 21, rave and hard-techno crates about 23-30). Prefer specific,
  niche-adjacent recommendations over generic mainstream similarity;
  popularity above ~70 is usually a miss outside canon classics.
- Listening is multilingual by default — Italian, French, English, Arabic
  and Moroccan, Spanish, German, Russian — plus reggae, reggaeton, and
  world music. Language is never a reason to filter out a recommendation.

### The playlist system

His playlists are a deliberate taxonomy — treat them as one:

- Naming is `<Genre> <emoji>`: country flags mark language or scene
  (`Rap 🇮🇹`, `Rap 🇫🇷`, `Rap 🇺🇲`, `Rap 🇲🇦`), object emojis mark genre
  (`Hard techno 🔨`, `Acid 🧪`, `Psy 🍄`, `Tribal 🪘`, `Piano 🎹`), and
  decades get their own lists (`60s 🎺`, `80s`, `90 🇮🇹`, `2000 🔥`,
  `Festivalbar Novanta / Duemila`).
- Rap is subdivided finest — by country, then by register: `Rap lyrical`,
  `Rap storytelling`, `Rap chill`, `Rap old school`, `Rap OG`,
  `Rap trap`, `Rap drill`, `Rap trash`. When filing rap, match the
  register, not just the country.
- Mood and context playlists carry identity beyond genre:
  `Vibe Coding 🧑‍💻` (work), `Downtempo 🌅` (chilling — melodic
  downtempo electronica in the vein of The Blaze and Kid Francescoli),
  `CLUB HELL - JOHN WICK MODE` and `BLADE BLOOD RAVE` (peak-time dark
  rave), `😩` and `💀` (moods), `Hackers`, `Camping ⛺`.
- A few playlists are single-artist shrines: `Capa`, `Peep`, `Babaman`,
  `Christopha`.
- Filing is disjoint: only ~7% of tracks live in more than one playlist.
  A track has one right home. When adding, pick the most specific match
  (`Rap storytelling 🇮🇹` over `Rap 🇮🇹` over `Misc`) and ask when two
  genuinely fit. `Misc` is the explicit catch-all — do not invent a new
  playlist when unsure.
- When creating a playlist, follow the naming scheme above.
- Curation is continuously active — playlists are living documents, not
  archives.

### Defaults

- No hard vetoes. Anything can be recommended when the quality and
  adjacency fit; judge by the positive signals above, not by exclusion
  rules.
- Asked to play music with no further instructions, play a bit of
  everything: mix across the pillars rather than locking onto one genre
  or stopping to ask. `spotctl playlist sample` draws a fair random
  slice across the whole taxonomy for exactly this.
- Discovery is a balanced mix: genuinely new artists and deeper cuts
  from the known canon in roughly equal measure, with canon adjacency as
  the bridge to new names.

### When to read his listening data

This profile is durable, so neither of these is part of the default flow.
Reach for them only when the request points at them:

- `spotctl top tracks|artists` — when he refers to his **favourites**:
  what he likes most, his top artists, what he listens to the most.
  `long_term` for "always", `medium_term` for "lately", `short_term`
  for "these weeks".
- `spotctl history recent` — when he refers to what he has **just been
  playing**: what he is on lately, what he was listening to before, more
  like what is playing now.

Otherwise skip both. They cost two network calls and a lot of context to
restate what this profile already says.

### Two modes

Queue requests come in two shapes and only one of them is expensive. Pick
by what he asks for, not by habit. He usually asks in Italian; judge the
request by what it means, not by matching English words.

**Extend** — *more like this, keep it going, more of the same, extend the
queue*. He is asking for continuity, not novelty. Resolve and queue,
nothing else: no playlist cache, no familiarity check, no `contains`
filtering. **Tracks he already has in his playlists are welcome here** —
a song he loves is a good answer to "more like this".

**Discovery** — *something new, stuff I don't know, surprise me, new
artists, let me discover something*. He is asking for things absent from
his library, so the filtering is the point:

1. `spotctl playlist cache --max-age 24h` once; never force a full
   refresh unless his playlists just changed.
2. Pick candidates from this profile, plus his listening data only if
   the request calls for it (see above), applying any genre, language,
   mood, or artist constraints.
3. Gauge familiarity with one bulk `spotctl playlist artists "NAME" ...`
   call: high track and playlist counts mean a well-known artist. When
   he asks for artists he knows less, prefer candidates with zero or low
   counts; when he asks for deep cuts, do the opposite.
4. Pick more candidates than requested and resolve them all with a
   single `spotctl resolve "artist title" ...` call — never one search
   per candidate, which is what made this flow take minutes. Verify each
   match is really the track asked for; Spotify's search returns a
   plausible wrong answer rather than nothing.
5. Bulk-check the IDs with one `spotctl playlist contains` call, keep
   only those where it is false, then report or queue exactly the
   requested number in the chosen order.

**When the request is ambiguous, treat it as Extend**, and say in one
line that the queue may include tracks he already owns and that he should
ask for new ones if he wanted only unfamiliar music. It is the cheap,
reversible mode: guessing wrong costs a sentence, while guessing wrong
the other way costs minutes.
