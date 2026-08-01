# Image models

## Gemini (`GEMINI_API_KEY`)

| Model | Also known as | Use for |
|---|---|---|
| `gemini-3-pro-image` | Nano Banana Pro | Default. Leads the image-editing arenas: best prompt adherence, legible text, multi-reference edits, brand consistency. |
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

## OpenAI (`OPENAI_API_KEY`, not configured yet)

| Model | Use for |
|---|---|
| `gpt-image-2` | Default. Tops the text-to-image arenas for prompt adherence and text rendering; reasons before generating, so it is the slowest and priciest option. |

`gpt-image-1` shuts down on 23 October 2026 — do not select it.

`--aspect-ratio` and `--size` are combined into the free-form `size` the API
wants (edges rounded to multiples of 16, at most 3840px, 0.65–8.3 MP), so any
listed ratio works at any tier. `--quality` (`low`/`medium`/`high`/`auto`,
default `high`) is separate and drives most of the per-image cost — drop it to
`low` or `medium` for drafts. The output format follows the `--output`
extension, so no renaming happens.

## Prompting

State subject, composition, style, palette, lighting, and mood explicitly; models
fill unstated details with generic choices. Name the medium ("flat vector
illustration", "35mm photo", "isometric 3D render") rather than an artist. Put
text that must appear in the image in quotes and keep it short.
