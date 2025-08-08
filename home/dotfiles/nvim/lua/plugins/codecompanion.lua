return {
	"olimorris/codecompanion.nvim",
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionCmd",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		strategies = {
			chat = {
				adapter = {
					name = "copilot",
					model = "claude-sonnet-4",
				},
			},
		},
	},
	keys = {
		{
			"<localleader>ac",
			"<CMD>CodeCompanionChat Toggle<CR>",
			desc = "Toggle a chat buffer",
			mode = { "n", "v" },
		},
		{
			"<localleader>aa",
			"<CMD>CodeCompanionChat Add<CR>",
			desc = "Add code to a chat buffer",
			mode = { "v" },
		},
		{
			"<localleader>ap",
			"<CMD>CodeCompanionActions<CR>",
			desc = "Open the action palette",
			mode = { "n", "v" },
		},
	},
}
