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

### Recommendation workflow

When asked to recommend or queue tracks he does not already have:

1. Run `spotctl playlist cache --max-age 24h` once; never force a full
   refresh unless his playlists just changed.
2. Use current top items, recent history, and this profile to guide
   discovery, applying any genre, language, mood, or artist constraints.
3. Gauge familiarity with a bulk `spotctl playlist artists "NAME" ...`
   call: high track and playlist counts mean a well-known artist. When
   he asks for artists he knows less, prefer candidates with zero or low
   counts; when he asks for deep cuts, do the opposite.
4. Search for more candidates than requested and resolve each to an
   exact track ID, then bulk-check them with one
   `spotctl playlist contains` call.
5. Keep only tracks where `contains` is false, then report or queue
   exactly the requested number in the chosen order.
