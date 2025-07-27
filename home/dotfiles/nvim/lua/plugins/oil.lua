return {
	"stevearc/oil.nvim",
	dependencies = {
		{ "echasnovski/mini.icons", opts = {} },
	},
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		default_file_explorer = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
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
