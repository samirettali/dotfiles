return {
	"bluz71/vim-moonfly-colors",
	priority = 1000,
	config = function()
		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyItalics = false

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				local palette = require("moonfly").palette
				vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey247 })
				vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey247 })
				vim.api.nvim_set_hl(0, "CursorLineNr", { bg = palette.black })
				vim.api.nvim_set_hl(0, "TroubleNormal", { bg = palette.black })
				vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = palette.black })
				vim.api.nvim_set_hl(0, "FoldColumn", { bg = palette.black, fg = palette.grey241 })
			end,
			group = vim.api.nvim_create_augroup("MoonflyHighlight", {}),
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
