/**
 * Context guard
 *
 * The pi side of guard-read.py: refuses to pull a whole large file into the
 * context (a `read` without `limit`, a `cat` of a big file in `bash`), and
 * warns once at each context threshold so a session is compacted or closed
 * before every call starts re-reading hundreds of thousands of tokens.
 */

import { readFileSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_LINES = Number(process.env.GUARD_MAX_LINES ?? 400);
const THRESHOLDS = [150_000, 200_000];
const DUMPERS = new Set(["cat", "less", "more", "bat", "batcat"]);

function lineCount(path: string): number | undefined {
  try {
    const text = readFileSync(path.replace(/^~/, process.env.HOME ?? ""), "utf8");
    return text.split("\n").length;
  } catch {
    return undefined;
  }
}

function advice(path: string, count: number): string {
  return `${path} has ${count} lines, more than the ${MAX_LINES} allowed in one read. Read the part you need with offset/limit, search it with grep, or delegate the reading to a subagent and keep only its answer: everything read here is re-sent on every call for the rest of the session.`;
}

function bigFileIn(command: string): string | undefined {
  for (const segment of command.split(/\|\||&&|[|;]/)) {
    const words = segment.trim().split(/\s+/);
    const name = words[0]?.split("/").pop() ?? "";
    if (!DUMPERS.has(name)) continue;
    for (const word of words.slice(1)) {
      if (word.startsWith("-")) continue;
      const count = lineCount(word);
      if (count && count > MAX_LINES) return advice(word, count);
    }
  }
  return undefined;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (event.toolName === "read") {
      const { path, limit } = event.input as { path: string; limit?: number };
      if (limit) return undefined;
      const count = lineCount(path);
      if (count && count > MAX_LINES) return { block: true, reason: advice(path, count) };
    }
    if (event.toolName === "bash") {
      const { command } = event.input as { command: string };
      const reason = bigFileIn(command);
      if (reason) return { block: true, reason };
    }
    return undefined;
  });

  let warned = 0;
  pi.on("session_start", () => {
    warned = 0;
  });
  pi.on("turn_end", async (_event, ctx) => {
    const tokens = ctx.getContextUsage()?.tokens;
    if (tokens == null) return;
    const reached = THRESHOLDS.filter((t) => tokens >= t).pop();
    if (!reached || reached <= warned) return;
    warned = reached;
    if (ctx.hasUI) {
      ctx.ui.notify(
        `Context at ${Math.round(tokens / 1000)}k: every call now re-reads it. /compact, or start a new session for the next task.`,
        "warning",
      );
    }
  });
}
