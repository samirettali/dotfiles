return {
	-- TODO: wait for https://github.com/bluz71/vim-moonfly-colors/pull/83
	"samirettali/vim-moonfly-colors",
	priority = 1000,
	lazy = false,
	config = function()
		local moonfly = require("moonfly")

		moonfly.custom_colors({ bg = "#000000" })

		local palette = moonfly.palette

		vim.opt.termguicolors = true
		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyVirtualTextColor = true
		vim.g.moonflyNormalFloat = true
		vim.g.moonflyUnderlineMatchParen = true
		vim.g.moonflyItalics = false

		local custom_highlight = vim.api.nvim_create_augroup("CustomHighlight", {})
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = custom_highlight,
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
					-- fg = palette.blue,
				})

				vim.api.nvim_set_hl(0, "TreesitterContext", {
					bg = palette.bg,
					-- fg = palette.blue,
				})

				-- TODO
				-- Pmenu
				-- PmenuSel
				-- PmenuSbar
				-- PmenuThumb
				-- WildMenu
				-- PmenuMatch
				-- PmenuMatchSel

				vim.api.nvim_set_hl(0, "PmenuMatch", {
					fg = palette.blue,
				})
			end,
			group = vim.api.nvim_create_augroup("MoonflyHighlight", {}),
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
