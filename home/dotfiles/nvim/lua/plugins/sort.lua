return {
	"sQVe/sort.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		mappings = {
			operator = "gs", -- this overrides the default gs mapping (goto sleep) but i never use it
			textobject = {
				inner = "is",
				around = "as",
			},
			motion = {
				next_delimiter = "]s",
				prev_delimiter = "[s",
			},
		},
	},
}
