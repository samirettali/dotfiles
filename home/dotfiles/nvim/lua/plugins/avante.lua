return {
	-- views can only be fully collapsed with the global statusline
	-- vim.opt.laststatus = 3
	-- Default splitting will cause your main splits to jump when opening an edgebar.
	-- To prevent this, set `splitkeep` to either `screen` or `topline`.
	-- vim.opt.splitkeep = "screen"
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
	opts = {
		-- add any opts here
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below is optional, make sure to setup it properly if you have lazy=true
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
