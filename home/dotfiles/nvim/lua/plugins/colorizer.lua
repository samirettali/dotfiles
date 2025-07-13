return {
	"catgoose/nvim-colorizer.lua",
	cmd = "ColorizerToggle",
	opts = {
		user_default_options = {
			mode = "virtualtext",
			names = false,
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
