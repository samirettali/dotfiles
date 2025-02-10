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
			},
			ft = { "markdown", "Avante" },
		},
	},
	opts = {
		provider = "ollama",
		vendors = {
			ollama = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "127.0.0.1:11434/v1",
				model = "qwen2.5-coder",
			},
		},
	},
}
