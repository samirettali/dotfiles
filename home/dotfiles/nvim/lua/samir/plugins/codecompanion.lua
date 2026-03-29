vim.pack.add({ "https://www.github.com/nvim-lua/plenary.nvim" })
-- vim.pack.add("https://github.com/nvim-treesitter/nvim-treesitter")
vim.pack.add({
	"https://www.github.com/olimorris/codecompanion.nvim",
})

-- Somewhere in your config
require("codecompanion").setup({
	adapters = {
		acp = {
			claude_code = function()
				return require("codecompanion.adapters").extend("claude_code", {
					env = {
						CLAUDE_CODE_OAUTH_TOKEN = "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",
					},
				})
			end,
		},
	},
	interactions = {
		chat = {
			opts = {
				completion_provider = "default",
			},
			adapter = {
				name = "claude_code",
				model = "sonnet",
			},
		},
		-- Or, just specify the adapter by name
		inline = {
			adapter = {
				name = "copilot",
				model = "claude-sonnet-4.6",
			},
		},
		cmd = {
			adapter = {
				name = "copilot",
				model = "claude-sonnet-4.6",
			},
		},
		background = {
			adapter = {
				name = "copilot",
				model = "claude-sonnet-4.6",
			},
		},
	},
})
