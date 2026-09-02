# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///

"""Generate songs with Lyria 3 through the Gemini API, several takes at once.

Every take is one generateContent call and lands as MP3. Lyria is
non-deterministic on lyric fidelity, so the usual loop is: generate N takes,
audit each against the intended lyrics with a Gemini audio model, keep the best.
"""

import argparse
import base64
import concurrent.futures
import json
import os
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

API = "https://generativelanguage.googleapis.com/v1beta/models"
PRO = "lyria-3-pro-preview"
CLIP = "lyria-3-clip-preview"
AUDIT_MODEL = "gemini-2.5-flash"

AUDIT_PROMPT = (
    "Listen to this song and compare it to the intended lyrics below. Report ONLY: "
    "(1) lines dropped, (2) lines repeated or echoed, (3) badly garbled passages "
    "with timestamps (ignore pure homophones), (4) whether the voice matches the "
    "requested one with no backing vocals, (5) quality 1-10 for the requested genre, "
    "(6) one-line verdict. Terse, no transcription.\n\nINTENDED:\n"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate music with Lyria 3.")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--prompt", help="Full prompt: direction, arrangement, lyrics")
    source.add_argument("--prompt-file", type=Path, help="UTF-8 file with the full prompt")
    parser.add_argument("--output-dir", type=Path, required=True, help="Directory for the takes")
    parser.add_argument("--name", default="take", help="Basename; takes become <name>-1.mp3, ...")
    parser.add_argument("--takes", type=int, default=1, help="How many takes to generate in parallel")
    parser.add_argument("--start", type=int, default=1, help="First take number")
    parser.add_argument("--model", default=PRO, help=f"{PRO} (default) or {CLIP}")
    parser.add_argument(
        "--probe",
        action="store_true",
        help=f"Only check whether the prompt passes the content filter, using {CLIP}; saves nothing",
    )
    parser.add_argument(
        "--audit",
        type=Path,
        help="Intended lyrics file; each take is compared against it with an audio model",
    )
    return parser.parse_args()


def post(model: str, body: dict, key: str) -> dict:
    request = urllib.request.Request(
        f"{API}/{model}:generateContent",
        data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=600) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        try:
            return json.load(error)
        except json.JSONDecodeError:
            return {"error": {"message": f"HTTP {error.code}"}}


def failure(response: dict) -> str | None:
    if "error" in response:
        return f"error: {response['error'].get('message', response['error'])}"
    block = response.get("promptFeedback", {}).get("blockReason")
    if block:
        return f"blocked: {block}"
    if not response.get("candidates"):
        return "error: no candidates"
    return None


def duration(path: Path) -> str:
    for tool, args in (("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0"]),):
        if shutil.which(tool):
            out = subprocess.run([tool, *args, str(path)], capture_output=True, text=True).stdout.strip()
            if out:
                return f"{float(out):.0f}s"
    if shutil.which("afinfo"):
        out = subprocess.run(["afinfo", str(path)], capture_output=True, text=True).stdout
        for line in out.splitlines():
            if "duration" in line:
                return f"{float(line.split()[-2]):.0f}s"
    return ""


def generate(args: argparse.Namespace, prompt: str, key: str, number: int) -> str:
    # generateContent returns MP3 and rejects every explicit audio mimeType;
    # WAV is only offered through the Interactions API.
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["AUDIO", "TEXT"]},
    }
    response = post(args.model, body, key)
    problem = failure(response)
    if problem:
        return f"{args.name}-{number}: {problem}"

    parts = response["candidates"][0]["content"]["parts"]
    audio = next((p["inlineData"] for p in parts if "inlineData" in p), None)
    if audio is None:
        return f"{args.name}-{number}: error: no audio in response"

    stem = args.output_dir / f"{args.name}-{number}"
    audio_path = stem.with_suffix(".mp3")
    audio_path.write_bytes(base64.b64decode(audio["data"]))
    text = "\n".join(p["text"] for p in parts if "text" in p)
    if text:
        stem.with_suffix(".txt").write_text(text, encoding="utf-8")

    line = f"{args.name}-{number}: ok {duration(audio_path)} {audio_path}"
    if args.audit:
        line += "\n" + audit(audio_path, audio["mimeType"], args.audit.read_text(encoding="utf-8"), key)
    return line


def audit(audio_path: Path, mime: str, intended: str, key: str) -> str:
    body = {
        "contents": [
            {
                "parts": [
                    {"inlineData": {"mimeType": mime, "data": base64.b64encode(audio_path.read_bytes()).decode()}},
                    {"text": AUDIT_PROMPT + intended},
                ]
            }
        ]
    }
    response = post(AUDIT_MODEL, body, key)
    problem = failure(response)
    if problem:
        return f"  audit {problem}"
    text = response["candidates"][0]["content"]["parts"][0].get("text", "")
    return "\n".join(f"  {line}" for line in text.strip().splitlines())


def main() -> None:
    args = parse_args()
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise SystemExit("GEMINI_API_KEY is not set")

    prompt = args.prompt if args.prompt is not None else args.prompt_file.read_text(encoding="utf-8")
    if not prompt.strip():
        raise SystemExit("prompt is empty")

    if args.probe:
        response = post(CLIP, {"contents": [{"parts": [{"text": prompt}]}]}, key)
        problem = failure(response)
        print(problem or "ok")
        sys.exit(1 if problem else 0)

    args.output_dir = args.output_dir.expanduser().resolve()
    if not args.output_dir.is_dir():
        raise SystemExit(f"output directory does not exist: {args.output_dir}")
    numbers = range(args.start, args.start + args.takes)
    clashes = [n for n in numbers if (args.output_dir / f"{args.name}-{n}.mp3").exists()]
    if clashes:
        raise SystemExit(f"takes already exist: {', '.join(f'{args.name}-{n}' for n in clashes)}")

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.takes) as pool:
        futures = [pool.submit(generate, args, prompt, key, n) for n in numbers]
        for future in futures:
            print(future.result(), flush=True)


if __name__ == "__main__":
    main()
