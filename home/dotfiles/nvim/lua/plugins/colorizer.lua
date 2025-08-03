return {
	"catgoose/nvim-colorizer.lua",
	cmd = "ColorizerToggle",
	opts = {
		user_default_options = {
			mode = "virtualtext",
			names = false,
			RRGGBBAA = true,
			AARRGGBB = true,
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			css_fn = true,
			-- boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
			tailwind = false, -- TODO
		},
	},
	keys = {
		{
			"<leader>th",
			function()
				vim.cmd("ColorizerToggle")
			end,
			desc = "Toggle colorizer",
		},
	},
}
