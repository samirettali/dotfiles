return {
	"nat-418/boole.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		-- TODO: this is broken
		mappings = {
			decrement = "<C-,>",
			increment = "<C-.>",
		},
	},
}
