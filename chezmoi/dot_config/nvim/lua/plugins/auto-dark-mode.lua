vim.pack.add({ "https://github.com/f-person/auto-dark-mode.nvim" })

require("auto-dark-mode").setup({
	set_dark_mode = function()
		vim.api.nvim_set_option_value("background", "dark", {})
		vim.cmd.colorscheme("moonfly")
	end,
	set_light_mode = function()
		vim.api.nvim_set_option_value("background", "light", {})
		vim.cmd.colorscheme("default")
	end,
	update_interval = 3000,
	fallback = "dark",
})
