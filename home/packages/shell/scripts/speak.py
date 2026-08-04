"""Stream text to speech through ElevenLabs and play it while it is generated.

Reads text from arguments, a file, or stdin and pipes the audio into a player as
it arrives, so playback starts before generation has finished.
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import threading
import urllib.error
import urllib.request
from pathlib import Path

from websockets.sync.client import connect

API_ROOT = "https://api.elevenlabs.io/v1"
WS_ROOT = "wss://api.elevenlabs.io/v1"
DEFAULT_VOICE = "CwhRBWXzGAHq8TQ4Fs17"  # Roger
DEFAULT_MODEL = "eleven_flash_v2_5"
DEFAULT_FORMAT = "mp3_44100_128"
DEFAULT_CUE = "Hmm…"
CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "speak"


def env(name: str, fallback: str) -> str:
    value = os.environ.get(name, "").strip()
    return value or fallback


def die(message: str) -> "NoReturn":  # noqa: F821
    print(f"speak: {message}", file=sys.stderr)
    raise SystemExit(1)


def api_key() -> str:
    key = os.environ.get("ELEVENLABS_API_KEY", "").strip()
    if not key:
        die("ELEVENLABS_API_KEY is not set")
    return key


# --- markdown -> speakable text -------------------------------------------------

FENCE = re.compile(r"^\s*(```|~~~)")
HEADING = re.compile(r"^\s{0,3}#{1,6}\s+")
LIST_MARKER = re.compile(r"^\s*([-*+]|\d+[.)])\s+")
QUOTE_MARKER = re.compile(r"^\s*>+\s?")
RULE = re.compile(r"^\s*([-*_])\s*(\1\s*){2,}$")
TABLE_ROW = re.compile(r"^\s*\|.*\|\s*$")
IMAGE = re.compile(r"!\[([^\]]*)\]\([^)]*\)")
LINK = re.compile(r"\[([^\]]+)\]\([^)]*\)")
BARE_URL = re.compile(r"\bhttps?://\S+")
EMPHASIS = re.compile(r"(\*\*|__|\*|_|`)")


class Sanitizer:
    """Turns streamed markdown lines into text worth listening to.

    Stateful because fenced code blocks span lines: everything inside a fence is
    replaced by a single spoken marker instead of being read out character by
    character.
    """

    def __init__(self, enabled: bool = True, code_marker: str = "code block.") -> None:
        self.enabled = enabled
        self.code_marker = code_marker
        self.in_fence = False

    def line(self, raw: str) -> str:
        if not self.enabled:
            return raw.strip()

        if FENCE.match(raw):
            self.in_fence = not self.in_fence
            return self.code_marker if not self.in_fence else ""
        if self.in_fence:
            return ""

        text = raw.strip()
        if not text or RULE.match(text) or TABLE_ROW.match(text):
            return ""

        text = QUOTE_MARKER.sub("", text)
        text = HEADING.sub("", text)
        text = LIST_MARKER.sub("", text)
        text = IMAGE.sub(r"\1", text)
        text = LINK.sub(r"\1", text)
        text = BARE_URL.sub("link", text)
        text = EMPHASIS.sub("", text)
        return re.sub(r"\s+", " ", text).strip()


# --- voices ---------------------------------------------------------------------


def http_json(path: str) -> dict:
    request = urllib.request.Request(f"{API_ROOT}{path}", headers={"xi-api-key": api_key()})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def resolve_voice(voice: str) -> str:
    """Accept either a voice id or a (prefix of a) voice name."""
    if re.fullmatch(r"[A-Za-z0-9]{20}", voice):
        return voice

    cache = CACHE_DIR / "voices.json"
    names: dict[str, str] = {}
    if cache.is_file():
        names = json.loads(cache.read_text())
    if voice.lower() not in names:
        names = {v["name"].split(" - ")[0].lower(): v["voice_id"] for v in http_json("/voices")["voices"]}
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps(names))

    resolved = names.get(voice.lower())
    if not resolved:
        die(f"unknown voice {voice!r}; run `speak --list-voices`")
    return resolved


def list_voices() -> None:
    for voice in http_json("/voices")["voices"]:
        print(f"{voice['voice_id']}\t{voice['name']}")


# --- playback -------------------------------------------------------------------


def start_player(args: argparse.Namespace) -> subprocess.Popen | None:
    if args.out:
        return None
    # --no-terminal is mandatory: speak runs inside TUIs (pi, Claude Code) and
    # mpv would otherwise take over the terminal and corrupt the interface.
    command = [
        "mpv",
        "--no-terminal",
        "--no-video",
        "--cache=no",
        "--keep-open=no",
        f"--volume={args.volume}",
        "-",
    ]
    return subprocess.Popen(command, stdin=subprocess.PIPE)


def sink(args: argparse.Namespace, player: subprocess.Popen | None):
    if player is not None:
        return player.stdin
    return open(args.out, "wb")


# --- synthesis ------------------------------------------------------------------


def voice_settings(args: argparse.Namespace) -> dict:
    return {
        "stability": args.stability,
        "similarity_boost": args.similarity,
        "speed": args.speed,
        "use_speaker_boost": True,
    }


def stream_speech(args: argparse.Namespace, lines) -> None:
    """Feed lines into the websocket while writing received audio to the sink."""
    voice_id = resolve_voice(args.voice)
    url = (
        f"{WS_ROOT}/text-to-speech/{voice_id}/stream-input"
        f"?model_id={args.model}&output_format={args.format}&auto_mode=true&inactivity_timeout=180"
    )

    player = start_player(args)
    output = sink(args, player)
    sanitizer = Sanitizer(enabled=not args.raw)
    spoke = False

    with connect(url, additional_headers={"xi-api-key": api_key()}) as socket:
        socket.send(json.dumps({"text": " ", "voice_settings": voice_settings(args)}))

        def receive() -> None:
            try:
                while True:
                    message = json.loads(socket.recv())
                    if message.get("audio"):
                        output.write(base64.b64decode(message["audio"]))
                        output.flush()
                    if message.get("isFinal"):
                        return
            except Exception:
                return

        receiver = threading.Thread(target=receive, daemon=True)
        receiver.start()

        try:
            for raw in lines:
                text = sanitizer.line(raw)
                if not text:
                    continue
                spoke = True
                socket.send(json.dumps({"text": f"{text} "}))
            socket.send(json.dumps({"text": ""}))
            receiver.join(timeout=args.timeout)
        finally:
            if player is not None and player.stdin is not None:
                player.stdin.close()
            elif player is None:
                output.close()

    if player is not None:
        player.wait()
    if not spoke and not args.quiet:
        print("speak: nothing to say", file=sys.stderr)


def synthesize(args: argparse.Namespace, text: str) -> bytes:
    voice_id = resolve_voice(args.voice)
    payload = json.dumps(
        {"text": text, "model_id": args.model, "voice_settings": voice_settings(args)}
    ).encode()
    request = urllib.request.Request(
        f"{API_ROOT}/text-to-speech/{voice_id}?output_format={args.format}",
        data=payload,
        headers={"xi-api-key": api_key(), "content-type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        die(f"elevenlabs returned {error.code}: {error.read().decode(errors='replace')[:200]}")


def play_cue(args: argparse.Namespace) -> None:
    """Play a short cached clip, generating it on first use.

    Used as the 'the model is thinking' earcon: regenerating it on every turn
    would burn characters for a sound that never changes.
    """
    text = args.cue or DEFAULT_CUE
    key = hashlib.sha1(f"{args.voice}\0{args.model}\0{args.format}\0{text}".encode()).hexdigest()[:16]
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    clip = CACHE_DIR / f"cue-{key}.mp3"

    if not clip.is_file():
        clip.write_bytes(synthesize(args, text))

    subprocess.run(
        ["mpv", "--no-terminal", "--no-video", f"--volume={args.volume}", str(clip)],
        check=False,
    )


# --- cli ------------------------------------------------------------------------


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="speak",
        description="Speak text with ElevenLabs, playing audio as it is generated.",
    )
    parser.add_argument("text", nargs="*", help="Text to speak; reads stdin when omitted")
    parser.add_argument("-f", "--file", type=Path, help="Read the text from a file")
    parser.add_argument(
        "--stream",
        action="store_true",
        help="Read stdin incrementally and speak each line as it arrives",
    )
    parser.add_argument("--voice", default=env("SPEAK_VOICE", DEFAULT_VOICE), help="Voice id or name")
    parser.add_argument("--model", default=env("SPEAK_MODEL", DEFAULT_MODEL))
    parser.add_argument("--format", default=env("SPEAK_FORMAT", DEFAULT_FORMAT))
    parser.add_argument("--speed", type=float, default=float(env("SPEAK_SPEED", "1.0")))
    parser.add_argument("--stability", type=float, default=float(env("SPEAK_STABILITY", "0.5")))
    parser.add_argument("--similarity", type=float, default=float(env("SPEAK_SIMILARITY", "0.75")))
    parser.add_argument("--volume", type=int, default=int(env("SPEAK_VOLUME", "100")))
    parser.add_argument("--raw", action="store_true", help="Do not strip markdown before speaking")
    parser.add_argument("--out", type=Path, help="Write audio to a file instead of playing it")
    parser.add_argument("--cue", nargs="?", const=DEFAULT_CUE, help="Play a short cached earcon")
    parser.add_argument("--list-voices", action="store_true")
    parser.add_argument("--timeout", type=float, default=120.0, help="Seconds to wait for audio")
    parser.add_argument("-q", "--quiet", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.list_voices:
        list_voices()
        return
    if args.cue is not None:
        play_cue(args)
        return

    if args.stream:
        stream_speech(args, iter(sys.stdin.readline, ""))
        return

    if args.file:
        source = args.file.read_text(encoding="utf-8")
    elif args.text:
        source = " ".join(args.text)
    else:
        source = sys.stdin.read()

    if not source.strip():
        die("no text to speak")
    stream_speech(args, source.splitlines())


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        raise SystemExit(130)
