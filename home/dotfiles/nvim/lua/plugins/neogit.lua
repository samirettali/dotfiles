return {
	"NeogitOrg/neogit",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"echasnovski/mini.pick",
	},
	opts = {},
	keys = {
		{
			"<localleader>g",
			"<CMD>Neogit<CR>",
		},
	},
}
