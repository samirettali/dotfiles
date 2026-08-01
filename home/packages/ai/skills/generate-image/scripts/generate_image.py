# /// script
# requires-python = ">=3.10"
# dependencies = ["google-genai==2.12.1", "httpx==0.28.1"]
# ///

import argparse
import base64
import mimetypes
import os
from pathlib import Path
import sys
import tempfile

ASPECT_RATIOS = ["1:1", "3:2", "2:3", "4:3", "3:4", "16:9", "9:16", "21:9", "5:4", "4:5"]

OPENAI_SIZES = {
    "1:1": "1024x1024",
    "16:9": "1536x1024",
    "3:2": "1536x1024",
    "4:3": "1536x1024",
    "9:16": "1024x1536",
    "2:3": "1024x1536",
    "3:4": "1024x1536",
}

DEFAULT_MODELS = {
    "gemini": "gemini-3-pro-image",
    "openai": "gpt-image-1",
}

SUFFIXES = {
    "image/png": ".png",
    "image/jpeg": ".jpg",
    "image/webp": ".webp",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate or edit an image with Gemini or OpenAI.")
    parser.add_argument("--prompt", required=True, help="Image description")
    parser.add_argument("--output", type=Path, required=True, help="Output .png, .jpg, or .webp path")
    parser.add_argument("--provider", choices=sorted(DEFAULT_MODELS), default="gemini")
    parser.add_argument("--model", help="Override the provider default model")
    parser.add_argument("--aspect-ratio", choices=ASPECT_RATIOS, default="1:1")
    parser.add_argument(
        "--size",
        choices=["1K", "2K", "4K"],
        default="1K",
        help="Gemini resolution; mapped to OpenAI quality low/medium/high",
    )
    parser.add_argument(
        "--reference",
        type=Path,
        action="append",
        default=[],
        help="Reference image to edit or draw style from; repeatable",
    )
    return parser.parse_args()


def read_reference(path: Path) -> tuple[bytes, str]:
    resolved = path.expanduser().resolve()
    if not resolved.is_file():
        raise SystemExit(f"reference image not found: {resolved}")
    mime, _ = mimetypes.guess_type(resolved.name)
    if mime is None or not mime.startswith("image/"):
        raise SystemExit(f"reference is not a recognized image: {resolved}")
    return resolved.read_bytes(), mime


def generate_gemini(args: argparse.Namespace, references: list[tuple[bytes, str]]) -> tuple[bytes, str]:
    from google import genai
    from google.genai import types

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise SystemExit("GEMINI_API_KEY is not set")

    contents: list = [args.prompt]
    for data, mime in references:
        contents.append(types.Part.from_bytes(data=data, mime_type=mime))

    client = genai.Client(api_key=api_key)
    response = client.models.generate_content(
        model=args.model or DEFAULT_MODELS["gemini"],
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(aspect_ratio=args.aspect_ratio, image_size=args.size),
        ),
    )

    for candidate in response.candidates or []:
        for part in candidate.content.parts or []:
            if part.inline_data is not None and part.inline_data.data:
                return part.inline_data.data, part.inline_data.mime_type or "image/png"
    raise SystemExit("Gemini returned no image; the prompt may have been blocked")


def generate_openai(args: argparse.Namespace, references: list[tuple[bytes, str]]) -> tuple[bytes, str]:
    import httpx

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise SystemExit("OPENAI_API_KEY is not set")

    size = OPENAI_SIZES.get(args.aspect_ratio)
    if size is None:
        raise SystemExit(f"--aspect-ratio {args.aspect_ratio} is not supported by OpenAI")
    quality = {"1K": "low", "2K": "medium", "4K": "high"}[args.size]

    output_format = args.output.suffix.lstrip(".").lower().replace("jpg", "jpeg")
    headers = {"Authorization": f"Bearer {api_key}"}
    data = {
        "model": args.model or DEFAULT_MODELS["openai"],
        "prompt": args.prompt,
        "size": size,
        "quality": quality,
        "n": "1",
        "output_format": output_format,
    }

    with httpx.Client(timeout=300) as client:
        if references:
            files = [
                ("image[]", (f"reference-{index}", payload, mime))
                for index, (payload, mime) in enumerate(references)
            ]
            response = client.post(
                "https://api.openai.com/v1/images/edits",
                headers=headers,
                data=data,
                files=files,
            )
        else:
            response = client.post(
                "https://api.openai.com/v1/images/generations",
                headers=headers,
                json={**data, "n": 1},
            )

    if response.status_code >= 400:
        raise SystemExit(f"OpenAI request failed ({response.status_code}): {response.text}")

    payload = response.json()["data"][0].get("b64_json")
    if not payload:
        raise SystemExit("OpenAI returned no image data")
    return base64.b64decode(payload), f"image/{output_format}"


def main() -> None:
    args = parse_args()

    output = args.output.expanduser().resolve()
    if output.suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
        raise SystemExit("--output must use a .png, .jpg, or .webp extension")
    if output.exists():
        raise SystemExit(f"output already exists: {output}")
    if not output.parent.is_dir():
        raise SystemExit(f"output directory does not exist: {output.parent}")
    if not args.prompt.strip():
        raise SystemExit("prompt is empty")

    references = [read_reference(path) for path in args.reference]
    generate = generate_gemini if args.provider == "gemini" else generate_openai
    image, mime = generate(args, references)

    suffix = SUFFIXES.get(mime, output.suffix)
    if suffix.lower() != output.suffix.lower().replace(".jpeg", ".jpg"):
        output = output.with_suffix(suffix)
        print(f"provider returned {mime}; writing {output.name} instead", file=sys.stderr)
        if output.exists():
            raise SystemExit(f"output already exists: {output}")

    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(dir=output.parent, suffix=output.suffix, delete=False) as temporary:
            temporary_path = Path(temporary.name)
            temporary.write(image)
        temporary_path.replace(output)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()

    print(output)


if __name__ == "__main__":
    main()
