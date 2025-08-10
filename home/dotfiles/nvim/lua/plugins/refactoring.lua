return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", branch = "main" },
		"nvim-lua/plenary.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
	keys = {
		{
			"<leader>rr",
			function()
				require("refactoring").select_refactor()
			end,
			mode = "v",
			desc = "Refactor",
		},
	},
}
