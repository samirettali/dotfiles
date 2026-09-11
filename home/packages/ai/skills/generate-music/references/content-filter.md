# The content filter

Blocked prompts return `promptFeedback.blockReason: PROHIBITED_CONTENT` with no
detail and no charge. The filter is cumulative: each section alone can pass while
the whole fails. Known triggers, all found by bisecting with `--probe`:

- Real artist names and brand names in the lyrics (Hugo TSR, Jeff Mills,
  Spotify, Chanel, Fleabag). Replace with periphrases.
- A style cue that points at one artist ("Paris eighteenth arrondissement
  underground") combined with lyrics that paraphrase that artist's structure.
  Describe the sound, not the scene.
- A repeated first name that reads as an artist. "Adee, Adee" in a hook was
  blocked as Adele; "Adélaïde" passed. Homophony with a famous name is enough.
- Personal data, sad themes, illness allusions and long lyrics did not trigger
  it on their own.

Bisect: probe each section alone, then pairs, then halves of the offending pair.
Six parallel probes settle it in one round. The filter moves: a prompt blocked
one evening passed unchanged the next morning, so probe the actual text rather
than reasoning from this list.
