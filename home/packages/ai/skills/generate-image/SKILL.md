---
name: generate-image
description: Generate or edit images from a text prompt with Gemini (nano banana) or OpenAI gpt-image. Use when the user asks to create an illustration, icon, logo draft, mockup, hero image, or to edit and restyle an existing image.
---

# Generate Image

Create images from a prompt, or edit existing ones by passing them as references.

## Generate

1. Require `GEMINI_API_KEY` in the environment (`OPENAI_API_KEY` for `--provider openai`). Never print or store it.
2. Pick a model from [references/models.md](references/models.md). The default `gemini-3-pro-image` is the right choice unless the user wants cheap drafts.
3. Use an output path that does not already exist.
4. Run the bundled script:

   ```sh
   uv run scripts/generate_image.py \
     --output /absolute/path/hero.png \
     --aspect-ratio 16:9 \
     --prompt 'Flat vector illustration of a terminal window, soft pastel palette, centered composition'
   ```

5. The script prints the absolute path it wrote. Gemini chooses the encoding itself, so the extension can come back as `.jpg` even when `.png` was requested — always report the printed path, not the requested one.

## Edit an existing image

Pass each source image with `--reference` (repeatable) and describe only the change:

```sh
uv run scripts/generate_image.py \
  --output /absolute/path/hero-fox.png \
  --reference /absolute/path/hero.png \
  --aspect-ratio 16:9 \
  --prompt 'Replace the cat with an orange fox, keep the same flat pastel style'
```

## Variations

Run the script once per variation with a distinct output path and a different model or prompt (`hero-a.png`, `hero-b.png`). Draft with `gemini-3.1-flash-image`, then regenerate the chosen direction with `gemini-3-pro-image`.

## Constraints

- Every call is a paid API request: generate one image per request and do not sweep models or aspect ratios unless asked.
- Do not overwrite existing images; the script refuses an existing output path.
- Use absolute output paths, and put generated images where the user asked — never in the dotfiles repo by default.
- Ask before generating images of real, identifiable people.
