return {
	"bluz71/vim-moonfly-colors",
	priority = 1000,
	lazy = false,
	config = function()
		local moonfly = require("moonfly")

		vim.opt.termguicolors = true
		vim.g.moonflyTerminalColors = true
		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyItalics = false
		vim.g.moonflyVirtualTextColor = true

		local custom_colors = {
			bg = "#000000",
		}

		moonfly.custom_colors(custom_colors)

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				local palette = require("moonfly").palette
				vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey247 })
				vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey247 })
			end,
			group = vim.api.nvim_create_augroup("MoonflyHighlight", {}),
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
