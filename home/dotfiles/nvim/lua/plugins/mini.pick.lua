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
			"<Cmd>Pick files<CR>",
		},
		{
			"<C-g>",
			"<Cmd>Pick grep_live<CR>",
		},
		{
			"<C-b>",
			"<Cmd>Pick buffers<CR>",
		},
	},
}
