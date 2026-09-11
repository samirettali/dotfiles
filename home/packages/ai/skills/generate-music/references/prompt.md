# Prompt structure

Three blocks, in this order, in one text.

1. **Musical direction**, prose: genre, BPM, key, instruments, mix character,
   the vocal (gender, register, timbre, rapping or singing), language, and the
   fidelity clause verbatim: "no ad-libs, no backing vocals, no repeated lines,
   perform each line exactly once, in order". State the total length.
2. **Arrangement**, one line per section with a timestamp window and bar count:
   `[0:37] Verse 2: full beat, exactly eight bars, one line per bar.` All
   performance directions live here, never inside the lyrics.
3. **Lyrics**, prefixed with `Lyrics:` and tagged `[Intro] [Verse] [Chorus]
   [Bridge] [Outro]`. Only words to perform.

**Make the arrangement window match the bar count.** At 92 BPM one bar is 2.6 s,
so eight lines need 21 s. Give a verse 26 s and the model fills the gap by
repeating lines; give it 18 s and it drops them. This was the single largest
source of repeated lines.

To get close to a beat the user liked in an earlier take, have a Gemini audio
model describe that take's instrumental in one paragraph and paste it as the
direction block. There is no seed and no audio input; the beat will still vary.

## Lyric rules that survive generation

- 11 to 14 syllables per line at 90 BPM, never above 15. Three clauses in one
  bar ("un client, un mois, un coup de fil") get fused or dropped.
- Everything after `Lyrics:` is performed literally: no parentheses, no
  quotation marks, no stage notes, no symbols.
- Spell proper nouns and foreign words phonetically for the song's language.
  Brand and place names are the words that garble most; a name that does not
  exist in the language ("Amarigg", "Serre-Ponçon", "Essaouira") is mangled in
  most takes whatever the spelling. Move it to a chorus line or accept it.
