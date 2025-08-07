return {
	"Bekaboo/dropbar.nvim",
	-- TODO: lazy loading might not be needed as the plugin already uses and autocmd
	-- https://github.com/Bekaboo/dropbar.nvim/blob/master/plugin/dropbar.lua
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		bar = {
			update_events = {
				win = {
					"CursorMoved",
					"CursorMovedI",
					"WinEnter",
					"WinResized",
				},
			},
			enable = function(buf, win, _)
				if
					not vim.api.nvim_buf_is_valid(buf)
					or not vim.api.nvim_win_is_valid(win)
					or vim.fn.win_gettype(win) ~= ""
					or vim.wo[win].winbar ~= ""
					or vim.bo[buf].ft == "help"
					or vim.bo[buf].ft == "codecompanion"
				then
					-- vim.notify("Dropbar: skipping buffer " .. vim.fn.win_gettype(win), vim.log.levels.WARN)
					return false
				end

				local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
				if stat and stat.size > 1024 * 1024 then
					return false
				end

				return vim.bo[buf].bt == "terminal"
					or vim.bo[buf].ft == "markdown"
					or pcall(vim.treesitter.get_parser, buf)
					or not vim.tbl_isempty(vim.lsp.get_clients({
						bufnr = buf,
						method = vim.lsp.protocol.Methods.textDocument_definition,
					}))
			end,
		},
		sources = {
			path = {
				relative_to = function(buf, win)
					-- Show full path in oil or fugitive buffers
					local bufname = vim.api.nvim_buf_get_name(buf)
					if vim.startswith(bufname, "oil://") or vim.startswith(bufname, "fugitive://") then
						local root = bufname:gsub("^%S+://", "", 1)
						while root and root ~= vim.fs.dirname(root) do
							root = vim.fs.dirname(root)
						end
						return root
					end

					local ok, cwd = pcall(vim.fn.getcwd, win)
					return ok and cwd or vim.fn.getcwd()
				end,
			},
		},
		icons = {
			kinds = {
				dir_icon = function(_)
					return ""
				end,
				-- symbols = {
				-- 	Folder = "x",
				-- },
			},
		},
	},
	init = function()
		local dropbar_api = require("dropbar.api")
		vim.keymap.set("n", "<localleader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
		vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
		vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		vim.ui.select = require("dropbar.utils.menu").select
	end,
}
