return {
	"nat-418/boole.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		mappings = {
			increment = "<C-a>",
			decrement = "<C-x>",
		},
	},
}
