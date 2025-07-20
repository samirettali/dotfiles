return {
	"nat-418/boole.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		mappings = {
			decrement = "<C-,>",
			increment = "<C-.>",
		},
	},
}
