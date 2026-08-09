## Samir's listening profile

Derived from his full listening data and playlist library. A durable starting
point — current top-item and recent-history data win when they disagree.

### Taste

- Two pillars, equal weight: rap and dark electronic. Neither is "the" main
  genre; he moves between them constantly.
- Electronic side is dark, high-energy, emotionally melodic: hard techno, rave,
  acid, trance, hardcore, makina, breakbeat, cinematic club. Anchors: Funk
  Tribu, 240 KM/H, DJ HEARTSTRING, Indecorum, Montee, Bad Boombox, Brutalismus
  3000, The Prodigy, Underworld, Daft Punk — plus the Blade, Matrix, John Wick
  and videogame-soundtrack aesthetic his playlist names cite. Mellow
  counterweight: melodic downtempo electronica, The Blaze an outright favorite
  (Kid Francescoli, Stavroz, Cubicolor nearby).
- Rap side is organized by scene. Italian lyrical and conscious rap is the
  deepest vein: Caparezza above all (all-time #1 artist, dedicated playlist),
  then Murubutu, Claver Gold, Mezzosangue, Mistaman, Ghemon, Cranio Randagio —
  alongside Italian trap and street rap (Shiva, Baby Gang, Simba La Rue, Rhove,
  Guè, Luchè). French rap is a long-term anchor (Alpha Wann, Hugo TSR, Nekfeu,
  Dinos, Freeze Corleone, IAM, Fonky Family).
- Classical is a pillar of its own, not a garnish: "Classical Music bangers" is
  one of his largest playlists, backed by orchestral, concerto, piano and
  ambient listening (Einaudi, Satie, film scores).
- Nu/alt metal recurs in rotation (System Of A Down, Metallica, Slipknot, Linkin
  Park). Melancholy cuts across everything: trip-hop, emo rap (Lil Peep),
  Apparat, Portishead, Massive Attack, Moby.
- Taste runs deep underground. Filed tracks average ~44 Spotify popularity, core
  scenes far lower (Italian lyrical rap ~21, rave and hard-techno crates ~23-30).
  Prefer specific, niche-adjacent picks over generic mainstream similarity;
  popularity above ~70 is usually a miss outside canon classics.
- Multilingual by default — Italian, French, English, Arabic and Moroccan,
  Spanish, German, Russian — plus reggae, reggaeton, world music. Language is
  never a reason to filter out a recommendation.

### The playlist system

A deliberate taxonomy. Treat it as one:

- Naming is `<Genre> <emoji>`. Country flags mark language or scene (`Rap 🇮🇹`,
  `Rap 🇫🇷`, `Rap 🇺🇲`, `Rap 🇲🇦`), object emojis mark genre (`Hard techno 🔨`,
  `Acid 🧪`, `Psy 🍄`, `Tribal 🪘`, `Piano 🎹`), decades get their own lists
  (`60s 🎺`, `80s`, `90 🇮🇹`, `2000 🔥`, `Festivalbar Novanta / Duemila`).
- Rap is subdivided finest — by country, then by register: `Rap lyrical`,
  `Rap storytelling`, `Rap chill`, `Rap old school`, `Rap OG`, `Rap trap`,
  `Rap drill`, `Rap trash`. Filing rap means matching the register, not just the
  country.
- Mood and context playlists carry identity beyond genre: `Vibe Coding 🧑‍💻`
  (work), `Downtempo 🌅` (chilling — melodic downtempo electronica in the vein of
  The Blaze and Kid Francescoli), `CLUB HELL - JOHN WICK MODE` and
  `BLADE BLOOD RAVE` (peak-time dark rave), `😩` and `💀` (moods), `Hackers`,
  `Camping ⛺`.
- Single-artist shrines: `Capa`, `Peep`, `Babaman`, `Christopha`.
- Filing is disjoint — only ~7% of tracks sit in more than one playlist. A track
  has one right home: pick the most specific match (`Rap storytelling 🇮🇹` over
  `Rap 🇮🇹` over `Misc`) and ask when two genuinely fit. `Misc` is the explicit
  catch-all; never invent a new playlist when unsure.
- Creating a playlist follows the naming scheme above.
- Curation is continuously active — playlists are living documents, not archives.

### Defaults

- No hard vetoes. Anything can be recommended when quality and adjacency fit;
  judge by the positive signals above, not by exclusion rules.
- Asked to play music with no further instructions: play a bit of everything,
  mixing across the pillars rather than locking onto one genre or stopping to
  ask. `spotctl playlist sample` draws a fair random slice across the whole
  taxonomy for exactly this.
- Discovery is a balanced mix: genuinely new artists and deeper cuts from the
  known canon in roughly equal measure, canon adjacency the bridge to new names.

### When to read his listening data

This profile is durable, so neither is part of the default flow. Reach for them
only when the request points at them:

- `spotctl top tracks|artists` — he refers to his **favourites**: what he likes
  most, his top artists, what he listens to the most. `long_term` for "always",
  `medium_term` for "lately", `short_term` for "these weeks".
- `spotctl history recent` — he refers to what he has **just been playing**: what
  he is on lately, what he was listening to before, more like what is on now.

Otherwise skip both. Two network calls and a lot of context to restate what this
profile already says.

### Two modes

Queue requests come in two shapes; only one is expensive. Pick by what he asks
for, not by habit. He usually asks in Italian — judge the request by meaning,
not by matching English words.

**Extend** — *more like this, keep it going, more of the same, extend the queue*.
Continuity, not novelty. Resolve and queue, nothing else: no playlist cache, no
familiarity check, no `contains` filtering. **Tracks he already owns are welcome
here** — a song he loves is a good answer to "more like this".

**Discovery** — *something new, stuff I don't know, surprise me, new artists, let
me discover something*. Things absent from his library, so the filtering is the
point:

1. `spotctl playlist cache --max-age 24h` once. Never force a full refresh
   unless his playlists just changed.
2. Pick candidates from this profile, plus his listening data only if the
   request calls for it (above), applying any genre, language, mood or artist
   constraint.
3. Gauge familiarity with one bulk `spotctl playlist artists "NAME" ...` call:
   high track and playlist counts mean a well-known artist. Asked for artists he
   knows less, prefer zero or low counts; asked for deep cuts, the opposite.
4. Pick more candidates than requested and resolve them all in a single
   `spotctl resolve "artist title" ...` call — never one search per candidate,
   which is what made this flow take minutes. Verify each match really is the
   track asked for: Spotify's search returns a plausible wrong answer rather
   than nothing.
5. Bulk-check the IDs with one `spotctl playlist contains` call, keep only the
   false ones, then report or queue exactly the requested number in the chosen
   order.

**Ambiguous request: treat it as Extend**, and say in one line that the queue may
include tracks he already owns and that he should ask for new ones if he wanted
only unfamiliar music. It is the cheap, reversible mode — guessing wrong costs a
sentence, guessing wrong the other way costs minutes.
