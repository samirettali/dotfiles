import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, Text, truncateToWidth } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("system-prompt", {
		description: "View the current system prompt",
		handler: async (_args, ctx) => {
			const prompt = ctx.getSystemPrompt();

			if (ctx.mode !== "tui") {
				console.log(prompt);
				return;
			}

			await ctx.ui.custom((_tui, theme, keybindings, done) => {
				const content = new Text(prompt, 1, 0);
				let contentLines: string[] = [];
				let renderedWidth = 0;
				let scrollOffset = 0;
				let pageSize = 1;

				const scrollTo = (offset: number) => {
					const maxOffset = Math.max(0, contentLines.length - pageSize);
					scrollOffset = Math.max(0, Math.min(offset, maxOffset));
					_tui.requestRender();
				};

				return {
					render: (width: number) => {
						if (width !== renderedWidth) {
							renderedWidth = width;
							contentLines = content.render(width);
						}

						pageSize = Math.max(1, _tui.terminal.rows - 6);
						scrollOffset = Math.min(scrollOffset, Math.max(0, contentLines.length - pageSize));
						const visibleLines = contentLines.slice(scrollOffset, scrollOffset + pageSize);
						const firstLine = contentLines.length === 0 ? 0 : scrollOffset + 1;
						const lastLine = Math.min(scrollOffset + pageSize, contentLines.length);
						const title = theme.fg("accent", theme.bold("System Prompt"));
						const help = theme.fg(
							"dim",
							`↑↓ scroll · PgUp/PgDn page · Home/End jump · Esc close · ${firstLine}-${lastLine}/${contentLines.length}`,
						);

						return [truncateToWidth(title, width), ...visibleLines, truncateToWidth(help, width)];
					},
					invalidate: () => {
						renderedWidth = 0;
						content.invalidate();
					},
					handleInput: (data: string) => {
						if (keybindings.matches(data, "tui.select.cancel") || keybindings.matches(data, "tui.select.confirm")) {
							done(undefined);
						} else if (keybindings.matches(data, "tui.select.up")) {
							scrollTo(scrollOffset - 1);
						} else if (keybindings.matches(data, "tui.select.down")) {
							scrollTo(scrollOffset + 1);
						} else if (keybindings.matches(data, "tui.select.pageUp")) {
							scrollTo(scrollOffset - pageSize);
						} else if (keybindings.matches(data, "tui.select.pageDown")) {
							scrollTo(scrollOffset + pageSize);
						} else if (keybindings.matches(data, "tui.altScreen.halfPageUp")) {
							scrollTo(scrollOffset - Math.max(1, Math.floor(pageSize / 2)));
						} else if (keybindings.matches(data, "tui.altScreen.halfPageDown")) {
							scrollTo(scrollOffset + Math.max(1, Math.floor(pageSize / 2)));
						} else if (matchesKey(data, "home")) {
							scrollTo(0);
						} else if (matchesKey(data, "end")) {
							scrollTo(contentLines.length);
						}
					},
				};
			});
		},
	});
}
