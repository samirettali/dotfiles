---
name: generate-music
description: Generate full songs with vocals and custom lyrics using Google Lyria 3 through the Gemini API. Use when the user asks to turn a text into a song, generate a rap or a track from lyrics, make a jingle, or iterate on takes of a generated song. Covers prompt structure, lyric rules that survive generation, the content filter, and the generate-audit-reroll loop.
---

# Generate Music

`generate-music` wraps Lyria 3 (`lyria-3-pro-preview`, full songs up to about
three minutes; `lyria-3-clip-preview`, 30 seconds). It carries the Gemini key
from the vault: never print or store it. Output is 48 kHz stereo MP3;
`generateContent` rejects every explicit audio format, WAV exists only through
the Interactions API, which this script does not use.

Lyric fidelity is non-deterministic. About one take in three drops, echoes or
garbles a line, so the unit of work is a batch of takes plus an audit, never one
call. Write the lyrics first, agree them with the user, then generate.

## Run

```sh
generate-music --prompt-file /abs/prompt.txt --output-dir /abs/dir \
  --name debout --takes 4 --audit /abs/intended.txt
```

- Takes run in parallel and land as `<name>-1.mp3`, `<name>-2.mp3`, ... plus a
  `.txt` with the lyrics and section timestamps Lyria actually used.
- `--audit FILE` compares each take against the intended lyrics with a Gemini
  audio model and prints dropped, repeated and garbled lines per take. `FILE` is
  the `Lyrics:` block of the prompt. Do not skip it: judging fidelity by ear
  from a transcript is slower and less reliable.
- `--probe` sends the prompt to the clip model and prints `ok` or the block
  reason, saving nothing. Use it to bisect a filter block before paying for
  full takes.
- `--start N` continues numbering across batches. Existing takes are never
  overwritten.
- Name versions, not numbers, once there are more than two: `--name portrait`,
  `--name debout`. Keep one prompt file per version next to the takes.

## Prompt structure

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

## The content filter

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

## Workflow

1. Write lyrics with the user in the loop, then freeze them in `intended.txt`.
2. `--probe` once. If blocked, bisect and rewrite; do not spend Pro calls.
3. Generate 3 to 5 takes with `--audit`. Report per take: dropped, repeated,
   garbled, duration. Homophones flagged by the audit ("Turin dort" heard as
   "Turin d'or") are not defects.
4. A line dropped in most takes is the line's fault: shorten it or split it,
   then reroll. Rerolling the same text rarely fixes a structural problem.
5. Hand the user the clean take by path and keep the rest; they often prefer
   the beat of a flawed one.

## Constraints

- The Gemini prepaid balance runs out silently: the API answers
  `429 RESOURCE_EXHAUSTED`. Stop, report the error text, and let the user top
  up at https://ai.studio/projects before retrying.
- Do not generate before the lyrics are agreed; each Pro take is billed.
- Never put the key in a prompt, a file, or a transcript.
