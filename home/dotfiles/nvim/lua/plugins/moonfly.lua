return {
	"bluz71/vim-moonfly-colors",
	priority = 1000,
	lazy = false,
	config = function()
		local moonfly = require("moonfly")

		moonfly.custom_colors({ bg = "#000000" })

		local palette = moonfly.palette

		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyVirtualTextColor = true
		vim.g.moonflyNormalFloat = true
		vim.g.moonflyUnderlineMatchParen = true -- TODO: needed?
		vim.g.moonflyItalics = false
		vim.g.moonflyUndercurls = false

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("MoonflyColors", { clear = true }),
			pattern = "moonfly",
			callback = function()
				vim.api.nvim_set_hl(0, "WinBar", {
					bg = palette.bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "WinBarNC", {
					bg = palette.bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "BqfSign", {
					bg = palette.bg,
					fg = palette.emerald,
				})

				vim.api.nvim_set_hl(0, "TablineSel", {
					bg = palette.bg,
					fg = palette.white,
				})

				vim.api.nvim_set_hl(0, "Tabline", {
					bg = palette.bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "TablineFill", {
					bg = palette.bg,
				})

				vim.api.nvim_set_hl(0, "TreesitterContext", {
					bg = palette.bg,
				})

				vim.api.nvim_set_hl(0, "StatusLine", {
					bg = palette.bg,
				})

				vim.api.nvim_set_hl(0, "NormalFloatPreview", {
					bg = palette.grey11,
				})

				vim.api.nvim_set_hl(0, "PmenuMatch", {
					fg = palette.blue,
				})
				vim.api.nvim_set_hl(0, "PounceMatch", {
					bg = palette.lime,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceUnmatched", {
					link = "Comment",
				})
				vim.api.nvim_set_hl(0, "PounceGap", {
					bg = palette.emerald,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceAccept", {
					bg = palette.orange,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceAcceptBest", {
					bg = palette.turquoise,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceCursor", {
					bg = palette.red,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceCursorGap", {
					bg = palette.cranberry,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceCursorAccept", {
					bg = palette.orange,
					fg = palette.grey11,
				})
				vim.api.nvim_set_hl(0, "PounceCursorAcceptBest", {
					bg = palette.turquoise,
					fg = palette.grey11,
				})
			end,
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
