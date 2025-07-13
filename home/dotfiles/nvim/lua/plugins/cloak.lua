return {
	-- Hide secrets in .env files
	"laytan/cloak.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		patterns = {
			{
				file_pattern = { ".env*", "*.env*" },
				cloak_pattern = "=.+",
			},
		},
	},
	keys = {
		"<leader>tc",
		"<cmd>CloakToggle<cr>",
		"n",
		silent = true,
		desc = "Toggle cloak.nvim",
	},
}
