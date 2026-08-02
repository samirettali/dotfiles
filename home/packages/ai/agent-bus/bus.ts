/**
 * Cross-session agent message bus.
 *
 * Layout under $AGENT_BUS_DIR (default $XDG_STATE_HOME/agent-bus):
 *   agents/<id>.json          presence record, pruned once the pid is gone
 *   inbox/<id>/<seq>.json     pending messages, deleted on drain
 *
 * Shared verbatim by the pi extension and the Claude Code hooks.
 */

import { createHash, randomUUID } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export type AgentKind = "pi" | "claude";

export interface AgentInfo {
    id: string;
    name: string;
    kind: AgentKind;
    cwd: string;
    pid: number;
    startedAt: string;
}

export interface Message {
    id: string;
    from: string;
    fromName: string;
    fromKind: AgentKind;
    text: string;
    sentAt: string;
}

export function busDir(): string {
    if (process.env.AGENT_BUS_DIR) return process.env.AGENT_BUS_DIR;
    const state = process.env.XDG_STATE_HOME || join(homedir(), ".local", "state");
    return join(state, "agent-bus");
}

const agentsDir = () => join(busDir(), "agents");

export const inboxDir = (id: string) => join(busDir(), "inbox", id);

/**
 * Short, human-typeable handle for a session. Hashed rather than sliced: pi
 * session files are named `<timestamp>_<uuid>.jsonl`, so any prefix of the raw
 * name collides across every session started the same day.
 */
export function shortId(sessionKey: string): string {
    return createHash("sha256").update(sessionKey).digest("hex").slice(0, 8);
}

function isAlive(pid: number): boolean {
    try {
        process.kill(pid, 0);
        return true;
    } catch (err) {
        return (err as NodeJS.ErrnoException).code === "EPERM";
    }
}

/** Idempotent: re-registering an existing id refreshes it without resetting startedAt. */
export function register(info: AgentInfo): void {
    mkdirSync(agentsDir(), { recursive: true });
    mkdirSync(inboxDir(info.id), { recursive: true });

    const path = join(agentsDir(), `${info.id}.json`);
    let startedAt = info.startedAt;
    if (existsSync(path)) {
        try {
            startedAt = (JSON.parse(readFileSync(path, "utf-8")) as AgentInfo).startedAt ?? startedAt;
        } catch {
            // Corrupt presence file; overwrite it wholesale.
        }
    }
    writeFileSync(path, JSON.stringify({ ...info, startedAt }, null, 2), "utf-8");
}

export function unregister(id: string): void {
    rmSync(join(agentsDir(), `${id}.json`), { force: true });
    rmSync(inboxDir(id), { recursive: true, force: true });
}

/** Live agents, sorted by start time. Presence files of dead processes are pruned. */
export function listAgents(): AgentInfo[] {
    const dir = agentsDir();
    if (!existsSync(dir)) return [];

    const agents: AgentInfo[] = [];
    for (const file of readdirSync(dir)) {
        if (!file.endsWith(".json")) continue;
        const path = join(dir, file);
        let info: AgentInfo;
        try {
            info = JSON.parse(readFileSync(path, "utf-8")) as AgentInfo;
        } catch {
            rmSync(path, { force: true });
            continue;
        }
        if (!isAlive(info.pid)) {
            unregister(info.id);
            continue;
        }
        agents.push(info);
    }
    return agents.sort((a, b) => a.startedAt.localeCompare(b.startedAt));
}

export type Resolution = { ok: true; agent: AgentInfo } | { ok: false; error: string };

/** Resolve a target by exact id, id prefix, exact name, then name substring. */
export function resolveTarget(query: string, exclude?: string): Resolution {
    const needle = query.trim().toLowerCase();
    const candidates = listAgents().filter((a) => a.id !== exclude);
    if (candidates.length === 0) return { ok: false, error: "no other agent sessions are running" };

    const tiers = [
        candidates.filter((a) => a.id === needle),
        candidates.filter((a) => a.id.startsWith(needle)),
        candidates.filter((a) => a.name.toLowerCase() === needle),
        candidates.filter((a) => a.name.toLowerCase().includes(needle)),
    ];

    for (const tier of tiers) {
        if (tier.length === 1) return { ok: true, agent: tier[0] };
        if (tier.length > 1) {
            const names = tier.map((a) => `${a.id} (${a.name})`).join(", ");
            return { ok: false, error: `"${query}" is ambiguous: ${names}` };
        }
    }

    const known = candidates.map((a) => `${a.id} (${a.name})`).join(", ");
    return { ok: false, error: `no agent matches "${query}". Running: ${known}` };
}

export function send(from: AgentInfo, target: AgentInfo, text: string): Message {
    const message: Message = {
        id: randomUUID(),
        from: from.id,
        fromName: from.name,
        fromKind: from.kind,
        text,
        sentAt: new Date().toISOString(),
    };
    const dir = inboxDir(target.id);
    mkdirSync(dir, { recursive: true });
    // Sortable file name so drain preserves send order.
    writeFileSync(join(dir, `${Date.now()}-${message.id}.json`), JSON.stringify(message), "utf-8");
    return message;
}

/** Read and remove every pending message for an agent. */
export function drain(id: string): Message[] {
    const dir = inboxDir(id);
    if (!existsSync(dir)) return [];

    const messages: Message[] = [];
    for (const file of readdirSync(dir).sort()) {
        if (!file.endsWith(".json")) continue;
        const path = join(dir, file);
        try {
            messages.push(JSON.parse(readFileSync(path, "utf-8")) as Message);
        } catch {
            // Ignore a half-written file; it will be picked up on the next drain.
            continue;
        }
        unlinkSync(path);
    }
    return messages;
}

export function formatMessages(messages: Message[]): string {
    const blocks = messages.map(
        (m) => `From ${m.fromName} (${m.fromKind}, id ${m.from}) at ${m.sentAt}:\n${m.text}`,
    );
    const plural = messages.length === 1 ? "message" : "messages";
    return [
        `You have ${messages.length} incoming ${plural} from another agent session.`,
        ...blocks,
        `Reply with agent_send / \`agent-bus send\` addressed to the sender's id if a response is warranted.`,
    ].join("\n\n");
}

export function formatAgentList(agents: AgentInfo[], selfId?: string): string {
    if (agents.length === 0) return "No agent sessions are running.";
    return agents
        .map((a) => `${a.id}  ${a.kind.padEnd(6)}  ${a.name}  ${a.cwd}${a.id === selfId ? "  (this session)" : ""}`)
        .join("\n");
}
