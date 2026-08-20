vim.pack.add({ "https://github.com/bluz71/vim-moonfly-colors" })

vim.g.moonflyTransparent = true
local moonfly = require("moonfly")

local palette = moonfly.palette

vim.g.moonflyWinSeparator = 2
vim.g.moonflyVirtualTextColor = true
vim.g.moonflyNormalFloat = true
vim.g.moonflyNormalPmenu = true
-- vim.g.moonflyUnderlineMatchParen = true -- TODO: needed?
vim.g.moonflyItalics = false
-- vim.g.moonflyUndercurls = true

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MoonflyColors", { clear = true }),
	pattern = "moonfly",
	callback = function()
		vim.api.nvim_set_hl(0, "WinBar", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "WinBarNC", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "BqfSign", {
			fg = palette.emerald,
		})

		vim.api.nvim_set_hl(0, "TablineSel", {
			fg = palette.white,
		})

		vim.api.nvim_set_hl(0, "Tabline", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "TreesitterContext", {
			bg = "NONE",
		})

		vim.api.nvim_set_hl(0, "StatusLine", {
			bg = "NONE",
		})

		vim.api.nvim_set_hl(0, "NormalFloatPreview", {
			bg = palette.grey11,
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
			bg = palette.red,
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
			bg = palette.red,
			fg = palette.grey11,
		})
	end,
})

vim.cmd.colorscheme("moonfly")
