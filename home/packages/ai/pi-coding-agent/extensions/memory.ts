/**
 * Persistent Project Memory Extension
 *
 * Maintains a MEMORY.md file as long-term project memory that the agent
 * reads at session start and updates throughout the session.
 *
 * - /memory or Alt+M to toggle on/off
 * - State persists per session
 * - When inactive, does nothing at all
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";
import { existsSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const CUSTOM_TYPE = "memory-state";
const MEMORY_FILE = "MEMORY.md";

const MEMORY_TEMPLATE = `# Project Memory

## Project Overview
<!-- What this project is and its goals -->

## Key Architecture / Decisions
<!-- Why things are the way they are -->

## Current State
<!-- What's in progress, what's done -->

## Notes / Gotchas
<!-- Things that bit us or are easy to forget -->

## Open Questions
<!-- Unresolved decisions -->
`;

const MEMORY_SYSTEM_PROMPT = `

## Persistent Memory

This project uses \`MEMORY.md\` as the long-term memory file.

- **At session start:** Read \`MEMORY.md\` silently before doing any work.
- **During the session:** Update \`MEMORY.md\` whenever you learn something worth remembering: architecture decisions, gotchas, file structure, tasks in progress, open questions.
- **At session end (if asked to wrap up):** Write a concise summary of what was done and what's next.
- Manage \`MEMORY.md\` autonomously — no asking permission.
- Keep entries concise. Prune stale entries.
`;

export default function memoryExtension(pi: ExtensionAPI) {
    let memoryEnabled = false;

    function updateStatus(ctx: ExtensionContext): void {
        if (memoryEnabled) {
            const theme = ctx.ui.theme;
            ctx.ui.setStatus("memory", theme.fg("accent", "🧠 Memory"));
        } else {
            ctx.ui.setStatus("memory", undefined);
        }
    }

    function ensureMemoryFile(cwd: string): void {
        const filePath = join(cwd, MEMORY_FILE);
        if (!existsSync(filePath)) {
            writeFileSync(filePath, MEMORY_TEMPLATE, "utf-8");
        }
    }

    function toggle(ctx: ExtensionContext): void {
        memoryEnabled = !memoryEnabled;
        pi.appendEntry(CUSTOM_TYPE, { enabled: memoryEnabled });

        if (memoryEnabled) {
            ensureMemoryFile(ctx.cwd);
            ctx.ui.notify("Memory enabled", "info");
        } else {
            ctx.ui.notify("Memory disabled", "info");
        }

        updateStatus(ctx);
    }

    pi.registerCommand("memory", {
        description: "Toggle persistent project memory (MEMORY.md)",
        handler: async (_args, ctx) => toggle(ctx),
    });

    pi.registerShortcut(Key.alt("m"), {
        description: "Toggle persistent project memory",
        handler: async (ctx) => toggle(ctx),
    });

    pi.on("session_start", async (_event, ctx) => {
        memoryEnabled = false;

        const entries = ctx.sessionManager.getEntries();
        for (let i = entries.length - 1; i >= 0; i--) {
            const entry = entries[i];
            if (entry.type === "custom" && entry.customType === CUSTOM_TYPE) {
                const data = entry.data as { enabled?: boolean } | undefined;
                memoryEnabled = data?.enabled ?? false;
                break;
            }
        }

        updateStatus(ctx);
    });

    pi.on("before_agent_start", async (event) => {
        if (!memoryEnabled) return undefined;

        return {
            systemPrompt: event.systemPrompt + MEMORY_SYSTEM_PROMPT,
        };
    });
}
