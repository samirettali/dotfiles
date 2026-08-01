# Image models

## Gemini (`GEMINI_API_KEY`)

| Model | Use for |
|---|---|
| `gemini-3-pro-image` | Default. Best prompt adherence, legible text in images, multi-reference edits. |
| `gemini-3.1-flash-image` | Fast and cheap drafts, variations, thumbnails. |
| `gemini-3.1-flash-lite-image` | Cheapest; simple graphics only. |
| `gemini-2.5-flash-image` | Previous generation; use only for reproducing older output. |

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
| `gpt-image-1` | Default. Strong instruction following and in-image text. |
| `gpt-image-1-mini` | Cheaper drafts. |

Aspect ratio maps to the three supported sizes (`1024x1024`, `1536x1024`,
`1024x1536`); `--size` maps to quality `low`/`medium`/`high`. The output format
follows the `--output` extension, so no renaming happens.

## Prompting

State subject, composition, style, palette, lighting, and mood explicitly; models
fill unstated details with generic choices. Name the medium ("flat vector
illustration", "35mm photo", "isometric 3D render") rather than an artist. Put
text that must appear in the image in quotes and keep it short.
