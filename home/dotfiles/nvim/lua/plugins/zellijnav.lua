return {
	"swaits/zellij-nav.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<c-h>",
			"<cmd>ZellijNavigateLeftTab<cr>",
			{ silent = true, desc = "Navigate left or tab" },
		},
		{
			"<c-j>",
			"<cmd>ZellijNavigateDown<cr>",
			{ silent = true, desc = "Navigate down" },
		},
		{
			"<c-k>",
			"<cmd>ZellijNavigateUp<cr>",
			{ silent = true, desc = "Navigate up" },
		},
		{
			"<c-l>",
			"<cmd>ZellijNavigateRightTab<cr>",
			{ silent = true, desc = "Navigate right or tab" },
		},
	},
	opts = {},
}
