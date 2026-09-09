---
name: generate-image
description: Generate or edit images from a text prompt with Gemini (nano banana) or OpenAI gpt-image. Use when the user asks to create an illustration, icon, logo draft, mockup, hero image, or to edit and restyle an existing image.
---

# Generate Image

Create images from a prompt, or edit existing ones by passing them as references.

## Generate

1. The `generate-image` command carries the keys: it reads them from the vault when the environment has none. Never print or store one.
2. Pick a model from [references/models.md](references/models.md), which also lists the Nano Banana names. The default is OpenAI `gpt-image-2.5-sunburst`. Use `--provider gemini` to select Gemini instead.
3. Use an output path that does not already exist.
4. Run it:

   ```sh
   generate-image \
     --output /absolute/path/hero.png \
     --aspect-ratio 16:9 \
     --prompt 'Flat vector illustration of a terminal window, soft pastel palette, centered composition'
   ```

5. The script prints the absolute path it wrote. Gemini chooses the encoding itself, so the extension can come back as `.jpg` even when `.png` was requested — always report the printed path, not the requested one.

For a near-Full-HD OpenAI image, use `--size 1920x1088 --quality medium`.
Explicit dimensions override `--aspect-ratio`. Exact 1920×1080 is unsupported:
OpenAI requires both edges to be divisible by 16. Do not silently resize or crop.

## Edit an existing image

Pass each source image with `--reference` (repeatable) and describe only the change:

```sh
generate-image \
  --output /absolute/path/hero-fox.png \
  --reference /absolute/path/hero.png \
  --aspect-ratio 16:9 \
  --prompt 'Replace the cat with an orange fox, keep the same flat pastel style'
```

## Variations

Run the script once per variation with a distinct output path and a different model or prompt (`hero-a.png`, `hero-b.png`). Use `--quality medium` or `--quality low` for OpenAI drafts, then regenerate the chosen direction at `--quality high`. Select older models explicitly with `--model gpt-image-2` when comparing.

## Constraints

- Every call is a paid API request: generate one image per request and do not sweep models or aspect ratios unless asked.
- Do not overwrite existing images; the script refuses an existing output path.
- Use absolute output paths, and put generated images where the user asked — never in the dotfiles repo by default.
- Ask before generating images of real, identifiable people.
