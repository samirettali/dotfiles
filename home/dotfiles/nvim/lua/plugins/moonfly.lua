return {
	"bluz71/vim-moonfly-colors",
	priority = 1000,
	lazy = false,
	config = function()
		local moonfly = require("moonfly")

		vim.opt.termguicolors = true
		vim.g.moonflyWinSeparator = 2
		vim.g.moonflyVirtualTextColor = true
		vim.g.moonflyNormalFloat = true
		vim.g.moonflyUnderlineMatchParen = true
		vim.g.moonflyItalics = false

		local custom_bg = "#000000"
		local custom_colors = {
			bg = custom_bg,
		}

		moonfly.custom_colors(custom_colors)

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				local palette = moonfly.palette

				vim.api.nvim_set_hl(0, "WinBar", {
					bg = custom_bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "WinBarNC", {
					bg = custom_bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "TablineSel", {
					bg = custom_bg,
					fg = palette.blue,
				})

				vim.api.nvim_set_hl(0, "Tabline", {
					bg = custom_bg,
					fg = palette.grey39,
				})

				vim.api.nvim_set_hl(0, "TablineFill", {
					bg = custom_bg,
					-- fg = palette.blue,
				})

				-- if vim.g.moonflyWinSeparator == 1 then
				-- 	vim.api.nvim_set_hl(0, "WinSeparator", {
				-- 		bg = palette.grey7,
				-- 		fg = palette.grey7,
				-- 	})
				-- end

				if vim.g.moonflyNormalFloat then
					vim.api.nvim_set_hl(0, "BlinkCmpSource", {
						bg = custom_bg,
					})
				end
			end,
			group = vim.api.nvim_create_augroup("MoonflyHighlight", {}),
		})

		vim.cmd.colorscheme("moonfly")
	end,
}
