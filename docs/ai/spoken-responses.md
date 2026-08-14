# Spoken responses

Read this before changing `speak` or pi's spoken-response extension.

`speak` lives at `home/packages/shell/scripts/speak.py`.
It streams text to ElevenLabs and plays audio while generation continues.

The pi extension `speak.ts` is a thin pipe.
It forwards assistant `text_delta` events into `speak --stream` and owns no synthesis logic.

Toggle speech with `/speak`.
Defaults come from `PI_SPEAK`.
The voice and model come from `SPEAK_VOICE` and `SPEAK_MODEL`.

## Design decisions

- Use the `stream-input` WebSocket with `auto_mode=true`, not the HTTP `/stream` endpoint.
  One connection per turn avoids seams and repeated request latency.
  ElevenLabs chooses sentence boundaries, so the client does not buffer for prosody.
- Run one process per turn, not per assistant message.
  A model can resume after tool calls, and separate message processes would overlap.
  Respawn on demand because a turn can outlive the WebSocket inactivity cap.
- Strip Markdown statefully before speaking.
  Fenced code blocks span lines and become the words "code block".
- Start mpv with `--no-terminal`.
  Otherwise it takes over the terminal and corrupts the surrounding TUI.
- Never speak thinking blocks.
  The first thinking block in a turn plays a cached earcon from `~/.cache/speak/`.

The ElevenLabs MCP server and `generate-speech` skill solve a different problem.
Use them for generated audio assets, not live spoken responses.
