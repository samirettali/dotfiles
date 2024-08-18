return {
	"bluz71/vim-moonfly-colors",
	priority = 1000,
	config = function()
		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyItalics = false

		local moonfly_highlights = vim.api.nvim_create_augroup("MoonflyHighlight", {})
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				local palette = require("moonfly").palette
				vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey247 })
				vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey247 })
				vim.api.nvim_set_hl(0, "CursorLineNr", { bg = palette.black })
			end,
			group = moonfly_highlights,
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
