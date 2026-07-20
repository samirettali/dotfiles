---
name: generate-speech
description: Generate multilingual WAV voice-overs and voice auditions from text with Gemini TTS. Use when the user asks to synthesize speech, narrate a demo video, compare Gemini voices, or create spoken audio in one or more languages.
---

# Generate Speech

Use Gemini TTS to create multilingual voice-overs. Preserve the supplied script exactly unless the user asks for rewriting.

## Generate audio

1. Require `GEMINI_API_KEY` in the environment. Never print or store it.
2. Choose a voice from [references/voices.md](references/voices.md). Default to `Kore` only when the user has no preference and does not want auditions.
3. Use a `.wav` output path that does not already exist.
4. Run the bundled script:

   ```sh
   uv run scripts/generate_speech.py \
     --output /absolute/path/voice-over.wav \
     --voice Kore \
     --text 'Testo da leggere'
   ```

   Use `--file` for longer scripts and `--instructions` for delivery guidance:

   ```sh
   uv run scripts/generate_speech.py \
     --output /absolute/path/voice-over.wav \
     --voice Sulafat \
     --instructions 'Speak warmly, at a measured pace, in a natural Italian accent.' \
     --file /absolute/path/script.txt
   ```

5. Verify that the output exists and is a non-empty WAV file, then return its absolute path.

## Audition voices

Select a small set based on the documented characteristics and generate the same short passage with each voice. Name samples predictably, such as `it-sulafat.wav` and `it-achird.wav`. Do not generate all voices unless explicitly requested; each sample is a separate API request.

## Constraints

- Require exactly one of `--text` or `--file`.
- Use `gemini-3.1-flash-tts-preview` unless the user explicitly requests another TTS model.
- Treat style, tone, accent, and pace as prompt instructions, not modifications to the script.
- Remember that Gemini TTS is a preview service: long output can drift, so split scripts longer than a few minutes.
- Do not overwrite existing audio files.
