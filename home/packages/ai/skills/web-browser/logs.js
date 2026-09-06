#!/usr/bin/env node
import { createReadStream, readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { createInterface } from "node:readline";
import { parseArgs } from "node:util";

try {
  const { values } = parseArgs({ options: {
    file: { type: "string" }, kind: { type: "string", default: "console" },
    filter: { type: "string" }, url: { type: "string" }, status: { type: "string" },
    since: { type: "string" }, limit: { type: "string", default: "100" },
    headers: { type: "string" },
  }});
  const limit = Number(values.limit);
  if (!Number.isInteger(limit) || limit < 1 || limit > 1000) throw new Error("--limit must be 1–1000");
  if (!["console", "network"].includes(values.kind)) throw new Error("--kind must be console or network");
  if (values.status && !/^[1-5]\d\d$/.test(values.status)) throw new Error("--status must be an HTTP status");
  if (values.since && !Number.isFinite(Date.parse(values.since))) throw new Error("--since must be a timestamp");
  let file = values.file;
  if (!file) {
    const root = join(homedir(), ".cache/agent-web/logs");
    const day = readdirSync(root).filter(name => /^\d{4}-\d{2}-\d{2}$/.test(name)).sort().at(-1);
    if (day) file = readdirSync(join(root, day)).filter(name => name.endsWith(".jsonl"))
      .map(name => join(root, day, name)).sort((a, b) => statSync(b).mtimeMs - statSync(a).mtimeMs)[0];
  }
  if (!file) throw new Error("No browser log found");
  console.error(`Reading ${file}`);
  const headers = new Set((values.headers || "").toLowerCase().split(",").filter(Boolean));
  const requests = new Map();
  const rows = [];
  const input = createReadStream(file);
  const lines = createInterface({ input, crlfDelay: Infinity });
  let readError;
  input.on("error", error => { readError = error; lines.close(); });
  for await (const line of lines) {
    let entry;
    try { entry = JSON.parse(line); } catch { continue; }
    const key = `${entry.targetId}:${entry.requestId}`;
    if (entry.type === "network.request") {
      requests.set(key, entry);
      if (requests.size > 10000) requests.delete(requests.keys().next().value);
      continue;
    }
    let text;
    if (["network.response", "network.failure"].includes(entry.type)) {
      const request = requests.get(key);
      if (entry.type === "network.failure") requests.delete(key);
      if (values.kind !== "network") continue;
      const url = entry.url || request?.url || "?";
      if (values.url && !url.includes(values.url)) continue;
      if (values.status && entry.status !== Number(values.status)) continue;
      text = `${entry.status ?? "ERR"} ${request?.method || "?"} ${url}${entry.errorText ? ` (${entry.errorText})` : ""}`;
      for (const [prefix, source] of [["→", request?.headers], ["←", entry.headers]]) {
        for (const [name, value] of Object.entries(source || {})) {
          if (headers.has(name.toLowerCase())) text += `\n  ${prefix} ${name}: ${value}`;
        }
      }
    } else if (values.kind === "console" && ["console", "exception", "log"].includes(entry.type)) {
      text = `${entry.level || entry.type}: ${entry.description || entry.text || (entry.args || []).map(arg => typeof arg.value === "string" ? arg.value : JSON.stringify(arg.value)).join(" ")}${entry.url ? ` @ ${entry.url}` : ""}`;
    } else continue;
    if (values.since && Date.parse(entry.ts) < Date.parse(values.since)) continue;
    if (values.filter && !text.includes(values.filter)) continue;
    rows.push(`[${entry.ts}] ${text}`);
    if (rows.length > limit) rows.shift();
  }
  if (readError) throw readError;
  const output = rows.join("\n") || "(empty)";
  const bytes = Buffer.from(output);
  process.stdout.write(bytes.subarray(0, 48000).toString());
  console.log(bytes.length > 48000 ? "\n[Truncated at 48KB; narrow filters or read the log file.]" : "");
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
