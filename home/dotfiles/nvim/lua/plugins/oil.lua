return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		default_file_explorer = true,
	},
	event = "VeryLazy",
	keys = {
		{
			"-",
			"<CMD>Oil<CR>",
			{ desc = "Open parent directory" },
		},
		{
			"_",
			"<CMD>Oil .<CR>",
			{ desc = "Open root directory" },
		},
	},
}
