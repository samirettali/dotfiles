return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {},
	keys = {
		-- {
		-- 	"<C-a>",
		-- 	"<cmd>CodeCompanionActions<CR>",
		-- 	desc = "Open the action palette",
		-- 	mode = { "n", "v" },
		-- },
		{
			"<leader>ap",
			":CodeCompanion<cr>",
			desc = "Open the action palette",
			mode = { "n", "v" },
		},
		{
			"<leader>ac",
			"<cmd>CodeCompanionChat Toggle<CR>",
			desc = "Toggle a chat buffer",
			mode = { "n", "v" },
		},
		{
			"<leader>aa",
			"<cmd>CodeCompanionChat Add<CR>",
			desc = "Add code to a chat buffer",
			mode = { "v" },
		},
	},
}
