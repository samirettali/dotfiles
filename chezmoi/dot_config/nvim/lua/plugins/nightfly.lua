vim.pack.add({ "https://github.com/bluz71/vim-nightfly-colors" })

local nightfly = require("nightfly")
-- nightfly.custom_colors({ bg = "#000000" })

local palette = nightfly.palette

vim.g.nightflyWinSeparator = 2
vim.g.nightflyVirtualTextColor = true
vim.g.nightflyNormalFloat = true
vim.g.nightflyNormalPmenu = true
-- vim.g.nightflyUnderlineMatchParen = true -- TODO: needed?
vim.g.nightflyItalics = false
-- vim.g.nightflyUndercurls = true

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("NightflyColors", { clear = true }),
	pattern = "nightfly",
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

		vim.api.nvim_set_hl(0, "CursorLine", {
			bg = palette.black,
		})

		vim.api.nvim_set_hl(0, "CursorLineNr", {
			bg = palette.black,
		})
	end,
})

-- vim.cmd.colorscheme("nightfly")
