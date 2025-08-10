return {
	"copilotlsp-nvim/copilot-lsp",
	opts = {
		nes = {
			move_count_threshold = 1,
		},
	},
	init = function()
		vim.g.copilot_nes_debounce = 0
		vim.lsp.enable("copilot_ls")
	end,
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<tab>",
			function()
				local bufnr = vim.api.nvim_get_current_buf()
				local state = vim.b[bufnr].nes_state
				if state then
					-- Try to jump to the start of the suggestion edit.
					-- If already at the start, then apply the pending suggestion and jump to the end of the edit.
					local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
						or (
							require("copilot-lsp.nes").apply_pending_nes()
							and require("copilot-lsp.nes").walk_cursor_end_edit()
						)
					return nil
				else
					-- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
					return "<C-i>"
				end
			end,
			mode = { "n", "i" },
			desc = "Accept Copilot suggestion (NES)",
		},
		{
			"<leader>tn",
			function()
				local clients = vim.lsp.get_clients({ name = "copilot_ls" })

				if #clients == 0 or clients[1]:is_stopped() then
					vim.lsp.enable("copilot_ls")
					vim.notify("Copilot LSP enabled", vim.log.levels.INFO)
				else
					vim.lsp.enalle("copilot_ls", false)
					vim.notify("Copilot LSP disabled", vim.log.levels.INFO)
				end
			end,
			desc = "Toggle Copilot (NES)",
		},
	},
}
