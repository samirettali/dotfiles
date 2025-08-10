return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"echasnovski/mini.pick",
	},
	cmd = "Neogit",
	opts = {},
	keys = {
		{
			"<localleader>g",
			"<CMD>Neogit<CR>",
		},
	},
}
