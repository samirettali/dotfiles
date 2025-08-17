return {
	"rlane/pounce.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		increase_cmd_height_if_zero = false,
	},
	keys = {
		{
			"<leader>j",
			"<CMD>Pounce<CR>",
			desc = "Pounce",
		},
		{
			"<leader>J",
			"<CMD>PounceRepeat<CR>",
			desc = "Pounce repeat",
		},
	},
}
