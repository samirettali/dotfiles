#!/usr/bin/env node
// Local editor for the pi model configuration. Serves app.html, proxies the
// OpenRouter catalog, and writes the dotfiles JSON. Applying is still `make build`.

import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const OPENROUTER = "https://openrouter.ai/api/v1";
const CATALOG_TTL = 10 * 60 * 1000;

const configPath =
  argValue("--config") ??
  process.env.PI_MODELS_CONFIG ??
  join(homedir(), "dev/dotfiles/home/packages/ai/pi-coding-agent/models.json");
const storePath = join(homedir(), ".pi/agent/models-store.json");

function argValue(flag) {
  const i = process.argv.indexOf(flag);
  return i === -1 ? undefined : process.argv[i + 1];
}

const cache = new Map();

async function cached(key, ttl, produce) {
  const hit = cache.get(key);
  if (hit && Date.now() - hit.at < ttl) return hit.value;
  const value = await produce();
  cache.set(key, { at: Date.now(), value });
  return value;
}

async function openrouter(path) {
  const res = await fetch(`${OPENROUTER}${path}`, {
    headers: { "User-Agent": "pi-models" },
    signal: AbortSignal.timeout(20000),
  });
  if (!res.ok) throw new Error(`OpenRouter ${path} → ${res.status}`);
  return res.json();
}

/**
 * What pi already knows, per provider, from its cached catalog overlay. The app needs the
 * actual inherited numbers — not just the provider names — so it can avoid writing an
 * override that only restates the built-in value.
 */
async function builtinCatalog() {
  try {
    const store = JSON.parse(await readFile(storePath, "utf8"));
    return Object.fromEntries(
      Object.entries(store).map(([provider, entry]) => [
        provider,
        Object.fromEntries(
          (entry?.models ?? []).map((m) => [
            m.id,
            { name: m.name ?? null, contextWindow: m.contextWindow ?? null, maxTokens: m.maxTokens ?? null },
          ]),
        ),
      ]),
    );
  } catch {
    // Without the cache we cannot tell redundant from meaningful, so claim to know nothing
    // and let every write through rather than silently dropping a limit the user wanted.
    return Object.fromEntries(
      ["openai-codex", "openrouter", "xai", "kimi-coding", "google", "openai"].map((p) => [p, {}]),
    );
  }
}

function endpointsFor(id) {
  return cached(`ep:${id}`, CATALOG_TTL, async () => {
    const payload = await openrouter(`/models/${id}/endpoints`);
    return (payload.data?.endpoints ?? []).map((e) => ({
      tag: e.tag,
      provider: String(e.tag ?? "").split("/")[0],
      quantization: e.quantization === "unknown" ? null : e.quantization,
      contextLength: e.context_length,
      maxCompletionTokens: e.max_completion_tokens,
      pricing: e.pricing ?? {},
      uptime: e.uptime_last_30m ?? null,
      supportedParameters: e.supported_parameters ?? [],
    }));
  });
}

/**
 * The rule the page applies on every pin, in one place: a limit is worth storing only when
 * the pinned provider disagrees with what pi would inherit anyway.
 */
function desiredLimits(endpoint, builtin) {
  const pick = (value, field) =>
    typeof value === "number" && !(builtin && builtin[field] === value) ? value : undefined;
  return {
    contextWindow: pick(endpoint.contextLength, "contextWindow"),
    maxTokens: pick(endpoint.maxCompletionTokens, "maxTokens"),
  };
}

function send(res, status, body, type = "application/json") {
  const payload = type === "application/json" ? JSON.stringify(body) : body;
  res.writeHead(status, { "content-type": type, "cache-control": "no-store" });
  res.end(payload);
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

const routes = {
  "GET /api/state": async () => ({
    path: configPath,
    config: JSON.parse(await readFile(configPath, "utf8")),
    builtins: await builtinCatalog(),
  }),

  "GET /api/catalog": () =>
    cached("catalog", CATALOG_TTL, async () => {
      const { data } = await openrouter("/models");
      return data.map((m) => ({
        id: m.id,
        name: m.name,
        // When OpenRouter listed it, which trails the vendor's announcement by days at most.
        created: m.created ?? null,
        contextLength: m.context_length,
        maxCompletionTokens: m.top_provider?.max_completion_tokens ?? null,
        pricing: m.pricing ?? {},
        inputModalities: m.architecture?.input_modalities ?? [],
        supportedParameters: m.supported_parameters ?? [],
        reasoning: m.reasoning ?? null,
      }));
    }),

  "PUT /api/config": async (req) => {
    const body = await readBody(req);
    if (!body || typeof body !== "object" || !Array.isArray(body.enabledModels)) {
      throw new Error("Refusing to write: payload has no enabledModels array");
    }
    await writeFile(configPath, `${JSON.stringify(body, null, 2)}\n`, "utf8");
    return { ok: true, path: configPath };
  },
};

// ---------- sync ----------

const fmtTokens = (v) =>
  typeof v !== "number" ? "inherited" : v >= 1e6 ? `${(v / 1e6).toFixed(1)}M` : v >= 1000 ? `${Math.round(v / 1000)}k` : String(v);

/** Every OpenRouter model that pins a provider, wherever its config happens to live. */
function pinnedEntries(config) {
  const block = config.providers?.openrouter ?? {};
  return [
    ...(block.models ?? []).map((m) => [m.id, m]),
    ...Object.entries(block.modelOverrides ?? {}),
  ].filter(([, entry]) => entry?.compat?.openRouterRouting?.only?.length);
}

async function sync() {
  const config = JSON.parse(await readFile(configPath, "utf8"));
  const builtins = await builtinCatalog();
  const entries = pinnedEntries(config);

  console.log(`pi-models --sync  ${configPath}\n`);
  if (!entries.length) {
    console.log("  No OpenRouter model pins a provider — nothing to sync.");
    return 0;
  }

  let updated = 0;
  let broken = 0;

  for (const [modelId, entry] of entries) {
    const pin = String(entry.compat.openRouterRouting.only[0]);
    console.log(`  ${modelId.padEnd(36)} ${pin}`);

    let endpoints;
    try {
      endpoints = await endpointsFor(modelId);
    } catch (err) {
      console.log(`    could not fetch endpoints: ${err.message}`);
      broken += 1;
      continue;
    }

    // A pin without a quantization matches any endpoint from that provider; with one it is exact.
    const endpoint = pin.includes("/")
      ? endpoints.find((e) => e.tag === pin)
      : endpoints.find((e) => e.provider === pin);

    if (!endpoint) {
      console.log(`    pinned provider is no longer offered for this model — left untouched`);
      broken += 1;
      continue;
    }

    const desired = desiredLimits(endpoint, builtins.openrouter?.[modelId] ?? null);
    let touched = false;

    for (const field of ["contextWindow", "maxTokens"]) {
      const before = entry[field];
      const after = desired[field];
      if (before === after) continue;

      if (after === undefined) {
        delete entry[field];
        console.log(`    ${field.padEnd(14)} ${fmtTokens(before)} -> inherited   (redundant, removed)`);
      } else {
        entry[field] = after;
        console.log(`    ${field.padEnd(14)} ${fmtTokens(before)} -> ${fmtTokens(after)}`);
      }
      touched = true;
    }

    if (!touched) console.log("    unchanged");
    if (touched) updated += 1;
  }

  console.log();
  if (updated) {
    await writeFile(configPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
    console.log(`${updated} model${updated === 1 ? "" : "s"} updated — run \`make build\` to apply`);
  } else {
    console.log("Everything already matches the pinned providers.");
  }
  if (broken) console.log(`${broken} model${broken === 1 ? "" : "s"} need attention (see above)`);
  return 0;
}

if (process.argv.includes("--sync")) {
  try {
    process.exit(await sync());
  } catch (err) {
    console.error(`pi-models --sync: ${err.message ?? err}`);
    process.exit(1);
  }
}

// ---------- server ----------

const server = createServer(async (req, res) => {
  const url = new URL(req.url, "http://localhost");
  const route = `${req.method} ${url.pathname}`;

  try {
    if (route === "GET /" || route === "GET /index.html") {
      return send(res, 200, await readFile(join(HERE, "app.html"), "utf8"), "text/html; charset=utf-8");
    }

    if (route === "GET /api/endpoints") {
      const id = url.searchParams.get("id");
      if (!id) return send(res, 400, { error: "missing id" });
      return send(res, 200, await endpointsFor(id));
    }

    const handler = routes[route];
    if (!handler) return send(res, 404, { error: "not found" });
    return send(res, 200, await handler(req));
  } catch (err) {
    send(res, 500, { error: String(err.message ?? err) });
  }
});

server.listen(0, "127.0.0.1", () => {
  const { port } = server.address();
  const url = `http://127.0.0.1:${port}/`;
  console.log(`pi-models  ${configPath}`);
  console.log(`           ${url}   (ctrl-c to stop)`);
  if (!process.argv.includes("--no-open")) {
    const opener = process.platform === "darwin" ? "open" : "xdg-open";
    spawn(opener, [url], { stdio: "ignore", detached: true }).unref();
  }
});
