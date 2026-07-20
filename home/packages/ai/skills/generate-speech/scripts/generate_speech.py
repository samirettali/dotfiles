# /// script
# requires-python = ">=3.10"
# dependencies = ["google-genai==2.12.1"]
# ///

import argparse
import base64
import os
from pathlib import Path
import tempfile
import wave

from google import genai


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a WAV file with Gemini TTS.")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--text", help="Text to synthesize")
    source.add_argument("--file", type=Path, help="UTF-8 text file to synthesize")
    parser.add_argument("--output", type=Path, required=True, help="Output .wav path")
    parser.add_argument("--voice", default="Kore", help="Gemini TTS voice name")
    parser.add_argument(
        "--instructions",
        default="Speak naturally and preserve the original language.",
        help="Delivery, accent, tone, and pacing instructions",
    )
    parser.add_argument(
        "--model",
        default="gemini-3.1-flash-tts-preview",
        help="Gemini TTS model",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise SystemExit("GEMINI_API_KEY is not set")

    output = args.output.expanduser().resolve()
    if output.suffix.lower() != ".wav":
        raise SystemExit("--output must use the .wav extension")
    if output.exists():
        raise SystemExit(f"output already exists: {output}")
    if not output.parent.is_dir():
        raise SystemExit(f"output directory does not exist: {output.parent}")

    text = args.text if args.text is not None else args.file.read_text(encoding="utf-8")
    if not text.strip():
        raise SystemExit("input text is empty")

    prompt = f"{args.instructions}\n\nRead the following text verbatim:\n{text}"
    client = genai.Client(api_key=api_key)
    interaction = client.interactions.create(
        model=args.model,
        input=prompt,
        response_format={"type": "audio"},
        generation_config={"speech_config": [{"voice": args.voice}]},
    )
    pcm = base64.b64decode(interaction.output_audio.data)
    if not pcm:
        raise SystemExit("Gemini returned empty audio")

    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(dir=output.parent, suffix=".wav", delete=False) as temporary:
            temporary_path = Path(temporary.name)
        with wave.open(str(temporary_path), "wb") as wav_file:
            wav_file.setnchannels(1)
            wav_file.setsampwidth(2)
            wav_file.setframerate(24000)
            wav_file.writeframes(pcm)
        temporary_path.replace(output)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()

    print(output)


if __name__ == "__main__":
    main()
