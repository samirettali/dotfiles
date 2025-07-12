return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
				heading = {
					enabled = false,
					sign = false,
				},
				code = {
					sign = false,
					border = "thin",
				},
			},
			ft = { "markdown", "Avante" },
		},
	},
	opts = {
		provider = "copilot",
		providers = {
			openrouter = {
				__inherited_from = "openai",
				endpoint = "https://openrouter.ai/api/v1",
				api_key_name = "OPENROUTER_API_KEY",
				model = "google/gemini-2.5-flash-preview-05-20:thinking",
			},
		},
	},
}
