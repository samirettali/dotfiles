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

		local custom_bg = "#000000"
		local custom_colors = {
			bg = custom_bg,
		}

		moonfly.custom_colors(custom_colors)

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				local palette = moonfly.palette

				local winbar_hl = vim.api.nvim_get_hl(0, { name = "WinBar", link = false })
				winbar_hl.bg = palette.grey16
				vim.api.nvim_set_hl(0, "WinBar", winbar_hl)

				local winbar_nc_hl = vim.api.nvim_get_hl(0, { name = "WinBarNC", link = false })
				winbar_nc_hl.bg = palette.grey7
				vim.api.nvim_set_hl(0, "WinBarNC", winbar_nc_hl)

				vim.api.nvim_set_hl(0, "TablineSel", {
					bg = palette.grey7,
					fg = palette.blue,
				})

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
