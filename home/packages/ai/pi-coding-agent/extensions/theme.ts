import {
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
	type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { EditorTheme, Theme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";

/** Rail plus gap on both sides of the editor content. */
const CHROME_WIDTH = 4;

function fillLine(content: string, width: number): string {
	const truncated = truncateToWidth(content, Math.max(0, width), "");
	return truncated + " ".repeat(Math.max(0, width - visibleWidth(truncated)));
}

/**
 * Pi's editor draws a plain rule above and below the text. This wraps the same
 * editor in a rounded frame, painting every piece through `this.borderColor` so
 * the frame keeps following the thinking level and bash mode.
 */
class FramedEditor extends CustomEditor {
	private frameWidth = 0;
	private topBorder = "";
	private bottomBorder = "";

	constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
		super(tui, theme, keybindings, { paddingX: 0 });
	}

	override setPaddingX(_padding: number): void {
		// The rail owns the horizontal inset, so the content keeps one stable gap.
		super.setPaddingX(0);
	}

	protected override renderTopBorder(_width: number, hiddenLineCount: number): string {
		this.topBorder = this.border("╭", "╮", "↑", hiddenLineCount);
		return this.topBorder;
	}

	protected override renderBottomBorder(_width: number, hiddenLineCount: number): string {
		this.bottomBorder = this.border("╰", "╯", "↓", hiddenLineCount);
		return this.bottomBorder;
	}

	private border(left: string, right: string, arrow: string, hiddenLineCount: number): string {
		const width = this.frameWidth;
		if (width < 2) return this.borderColor(truncateToWidth(left + right, width, ""));

		const inner = width - 2;
		let fill = "─".repeat(inner);
		if (hiddenLineCount > 0) {
			const label = ` ${arrow} ${hiddenLineCount} more `;
			const labelWidth = visibleWidth(label);
			if (labelWidth <= inner) {
				const before = Math.floor((inner - labelWidth) / 2);
				fill = "─".repeat(before) + label + "─".repeat(inner - before - labelWidth);
			}
		}
		return this.borderColor(left + fill + right);
	}

	override render(width: number): string[] {
		if (width < CHROME_WIDTH) return super.render(width);

		this.frameWidth = width;
		const inner = width - CHROME_WIDTH;
		const lines = super.render(inner);
		// Autocomplete rows follow the bottom border.
		const bottom = this.bottomBorder ? lines.lastIndexOf(this.bottomBorder) : -1;
		const lastFramed = bottom === -1 ? lines.length - 1 : bottom;
		const rail = this.borderColor("│");

		const framed = lines.slice(0, lastFramed + 1).map((line, index) => {
			if (index === 0 || index === lastFramed) return line;
			return `${rail} ${fillLine(line, inner)} ${rail}`;
		});
		// The completion menu belongs above the box, the way Claude Code shows it,
		// so the prompt keeps its place instead of being pushed up the screen.
		const menu = lines.slice(lastFramed + 1).map((line) => `  ${line}`);
		return [...menu, ...framed].map((line) => truncateToWidth(line, width, ""));
	}
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

/**
 * Cumulative session usage, counted the way Pi's own footer counts it: every
 * entry in the session rather than the current branch, including tool results
 * and the usage carried by compaction and branch summaries.
 */
function usageTotals(ctx: ExtensionContext): { input: number; output: number } {
	let input = 0;
	let output = 0;
	const add = (usage: { input?: number; output?: number } | undefined) => {
		if (!usage) return;
		input += usage.input ?? 0;
		output += usage.output ?? 0;
	};

	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			add(entry.message.usage);
		} else if (entry.type === "message" && entry.message.role === "toolResult") {
			add(entry.message.usage);
		} else if (entry.type === "branch_summary" || entry.type === "compaction") {
			add(entry.usage);
		}
	}
	return { input, output };
}

function installFooter(ctx: ExtensionContext): void {
	ctx.ui.setFooter((_tui, theme) => {
		return {
			invalidate() {},
			render: (width: number): string[] => renderFooter(ctx, theme, width),
		};
	});
}

function renderFooter(ctx: ExtensionContext, theme: Theme, width: number): string[] {
	const sep = theme.fg("dim", " | ");

	const left: string[] = [theme.fg("accent", basename(ctx.cwd) || ctx.cwd)];
	const sessionName = ctx.sessionManager.getSessionName();
	if (sessionName) left.push(theme.fg("syntaxVariable", sessionName));
	const model = ctx.model;
	if (model) {
		const parts = [theme.fg("syntaxFunction", model.id)];
		if (model.provider) {
			parts.unshift(theme.fg("muted", model.provider) + theme.fg("dim", "/"));
		}
		const thinking = ctx.thinkingLevel;
		if (thinking && thinking !== "off") {
			parts.push(theme.fg("dim", " · ") + theme.fg("muted", thinking));
		}
		left.push(parts.join(""));
	}

	const { input, output } = usageTotals(ctx);
	const usage = ctx.getContextUsage();
	const percent = usage?.percent;
	const right: string[] = [
		theme.fg("success", `↑${formatTokens(input)}`),
		theme.fg("accent", `↓${formatTokens(output)}`),
	];
	if (percent !== null && percent !== undefined && Number.isFinite(percent)) {
		const rounded = Math.round(percent);
		const color = rounded >= 90 ? "error" : rounded >= 70 ? "warning" : "muted";
		right.push(theme.fg(color, `${rounded}%`));
	}

	const leftText = left.join(sep);
	const rightText = right.join(sep);
	const gap = width - 2 - visibleWidth(leftText) - visibleWidth(rightText);
	if (gap < 1) return [truncateToWidth(` ${leftText}`, width, "")];
	return [` ${leftText}${" ".repeat(gap)}${rightText} `];
}

function piVersion(): string | undefined {
	const packageDir = process.env.PI_PACKAGE_DIR;
	if (!packageDir) return undefined;
	try {
		const manifest = JSON.parse(readFileSync(join(packageDir, "package.json"), "utf8"));
		return typeof manifest.version === "string" ? manifest.version : undefined;
	} catch {
		return undefined;
	}
}

/** Directories Pi walks up to, per its skill and context discovery rules. */
function ancestors(from: string): string[] {
	const paths: string[] = [];
	let current = from;
	while (true) {
		paths.push(current);
		if (existsSync(join(current, ".git"))) break;
		const parent = dirname(current);
		if (parent === current) break;
		current = parent;
	}
	return paths;
}

/** Count skills the way Pi discovers them: directories holding a SKILL.md. */
function countSkills(root: string): number {
	if (!existsSync(root)) return 0;
	let count = 0;
	const walk = (dir: string) => {
		let entries: string[];
		try {
			entries = readdirSync(dir);
		} catch {
			return;
		}
		if (entries.includes("SKILL.md")) {
			count++;
			return;
		}
		for (const entry of entries) {
			const path = join(dir, entry);
			try {
				if (statSync(path).isDirectory()) walk(path);
			} catch {
				// Broken symlink, nothing to count.
			}
		}
	};
	walk(root);
	return count;
}

function headerLines(ctx: ExtensionContext, theme: Theme): string[] {
	const home = homedir();
	const sep = theme.fg("dim", " | ");

	const version = piVersion();
	const parts: string[] = [
		theme.fg("accent", "pi") + (version ? theme.fg("dim", ` v${version}`) : ""),
	];

	const projectDirs = ancestors(ctx.cwd);
	const contextFiles = [
		join(home, ".pi", "agent", "AGENTS.md"),
		...projectDirs.map((dir) => join(dir, "AGENTS.md")),
	].filter((path) => existsSync(path));
	if (contextFiles.length > 0) {
		parts.push(theme.fg("muted", `${contextFiles.length} × AGENTS.md`));
	}

	const globalSkills =
		countSkills(join(home, ".pi", "agent", "skills")) +
		countSkills(join(home, ".agents", "skills"));
	const projectSkills = projectDirs.reduce(
		(total, dir) => total + countSkills(join(dir, ".pi", "skills")) + countSkills(join(dir, ".agents", "skills")),
		0,
	);
	const skills = theme.fg("muted", `${globalSkills} global skills`);
	parts.push(
		projectSkills > 0
			? skills + theme.fg("dim", " · ") + theme.fg("muted", `${projectSkills} project`)
			: skills,
	);

	// One column of inset, matching the footer.
	return [` ${parts.join(sep)}`];
}

/**
 * Pi's own startup header is silenced by `quietStartup`. This is the short
 * version: what Pi is, and what it picked up for this directory. It sits in
 * Pi's header slot, at the top of the transcript, and scrolls away with it.
 */
function installHeader(ctx: ExtensionContext): void {
	ctx.ui.setHeader((_tui, theme) => ({
		invalidate() {},
		render: () => [...headerLines(ctx, theme), ""],
	}));
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		ctx.ui.setEditorComponent(
			(tui, theme, keybindings) => new FramedEditor(tui, theme, keybindings),
		);
		installFooter(ctx);
		installHeader(ctx);
	});
}
