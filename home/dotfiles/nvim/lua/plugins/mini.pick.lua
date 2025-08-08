return {
	"echasnovski/mini.pick",
	event = "VeryLazy",
	version = false,
	opts = {
		mappings = {
			select_all_to_qf = {
				char = "<C-q>",
				func = function()
					local matches = require("mini.pick").get_picker_matches()
					if not matches or not matches.all or #matches.all == 0 then
						return false
					end

					require("mini.pick").default_choose_marked(matches.all)

					-- stop the picker after sending to the quickfix list
					return true
				end,
			},
		},
	},
	keys = {
		{
			"<C-f>",
			"<CMD>Pick files<CR>",
			desc = "Pick files",
		},
		{
			"<C-g>",
			"<CMD>Pick grep_live<CR>",
			desc = "Pick grep live",
		},
		{
			"<leader>fb",
			"<CMD>Pick buffers<CR>",
			desc = "Pick buffers",
		},
		{
			"<leader>fr",
			"<CMD>Pick resume<CR>",
			desc = "Resume picker",
		},
		{
			"<leader>fh",
			"<CMD>Pick help<CR>",
			desc = "Pick help",
		},
	},
}
