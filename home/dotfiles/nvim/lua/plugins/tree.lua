return {
	"nvim-tree/nvim-tree.lua",
	opts = {
		view = {
			side = "right",
		},
		renderer = {
			icons = {
				show = {
					git = true,
				},
			},
		},
		update_focused_file = {
			enable = true,
		},
	},
	keys = {
		{ "<C-t>", ":NvimTreeToggle<CR>" },
	},
}
