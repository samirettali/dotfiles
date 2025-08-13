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
		{ "nvim-treesitter/nvim-treesitter", branch = "main" },
		"franco-ruggeri/codecompanion-spinner.nvim",
		"ravitemer/codecompanion-history.nvim",
	},
	opts = {
		extensions = {
			spinner = {},
		},
		strategies = {
			chat = {
				opts = {
					completion_provider = "default",
				},
				adapter = {
					name = "copilot",
					model = "claude-sonnet-4",
				},
				keymaps = {
					completion = {
						modes = {
							i = "<C-x>",
						},
						index = 1,
						callback = "keymaps.completion",
						description = "Completion Menu",
					},
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
