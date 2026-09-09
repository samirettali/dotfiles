# Image models

## Gemini (`GEMINI_API_KEY`)

| Model | Also known as | Use for |
|---|---|---|
| `gemini-3-pro-image` | Nano Banana Pro | Gemini default. Image editing, legible text, multi-reference edits, brand consistency. |
| `gemini-3.1-flash-image` | Nano Banana 2 | Generalist workhorse. Fast drafts, variations, high-volume work; still handles 4K and in-image text well. |
| `gemini-3.1-flash-lite-image` | Nano Banana 2 Lite | Cheapest; simple graphics only. |

Use the GA ids above: the `-preview` aliases were shut down on 25 June 2026. The
Imagen models are deprecated and shut down on 17 August 2026; do not use them.

Gemini decides the output encoding itself (often JPEG) — the API has no output
format option, so the script writes the extension the provider actually returned.

`--size` maps to the long edge: `1K`, `2K`, `4K`. `4K` is only worth it for print
or large hero images.

Reference images (`--reference`, repeatable) drive editing, style transfer, and
character consistency. Describe in the prompt what to keep from each reference and
what to change; up to three references stay reliable.

## OpenAI (`OPENAI_API_KEY`)

| Model | Use for |
|---|---|
| `gpt-image-2.5-sunburst` | Skill and CLI default. OpenAI's most capable image generation and editing model. |
| `gpt-image-2.5-flare` | Faster everyday image generation. Select explicitly. |
| `gpt-image-2` | Previous generation; retain for comparisons. |

Model IDs and capabilities: [Sunburst](https://developers.openai.com/api/docs/models/gpt-image-2.5-sunburst),
[image generation guide](https://developers.openai.com/api/docs/guides/image-generation).
Sunburst and Flare use the same token rates as GPT Image 2, not necessarily the
same tokens per image. Compare actual API usage rather than reusing the GPT Image 2 calculator.

`gpt-image-1` shuts down on 23 October 2026 — do not select it.

`--aspect-ratio` and `--size` are combined into the free-form `size` the API
wants (edges rounded to multiples of 16, at most 3840px, 0.65–8.3 MP), so any
listed ratio works at any tier. Alternatively, pass `--size WIDTHxHEIGHT` to
set exact dimensions, overriding the aspect ratio. Edges must be divisible by 16,
the aspect ratio must be 1:3–3:1, and the same pixel bounds apply.
Use `1920x1088` for near Full HD; `1920x1080` is not accepted.
`--quality` (`low`/`medium`/`high`/`auto`,
default `high`) is separate and drives most of the per-image cost — drop it to
`low` or `medium` for drafts. The output format follows the `--output`
extension, so no renaming happens.

## Prompting

State subject, composition, style, palette, lighting, and mood explicitly; models
fill unstated details with generic choices. Name the medium ("flat vector
illustration", "35mm photo", "isometric 3D render") rather than an artist. Put
text that must appear in the image in quotes and keep it short.
