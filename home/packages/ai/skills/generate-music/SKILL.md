---
name: generate-music
disable-model-invocation: true
description: Generate full songs with vocals and custom lyrics using Google Lyria 3 through the Gemini API. Use when the user asks to turn a text into a song, generate a rap or a track from lyrics, make a jingle, or iterate on takes of a generated song. Covers prompt structure, lyric rules that survive generation, the content filter, and the generate-audit-reroll loop.
---

# Generate Music

`generate-music` wraps Lyria 3 (`lyria-3-pro-preview`, full songs up to about
three minutes; `lyria-3-clip-preview`, 30 seconds). Output is 48 kHz stereo MP3;
`generateContent` rejects every explicit audio format, WAV exists only through
the Interactions API, which this script does not use.

Lyric fidelity is non-deterministic. About one take in three drops, echoes or
garbles a line, so the unit of work is a batch of takes plus an audit, never one
call. Write the lyrics first, agree them with the user, then generate.

Read the reference for the step, relative to this skill:

| Work | Read |
| --- | --- |
| Writing the prompt or the lyrics | [Prompt](references/prompt.md) |
| A probe or a take is blocked | [Content filter](references/content-filter.md) |

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
