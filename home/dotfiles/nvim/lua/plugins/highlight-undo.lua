return {
	"tzachar/highlight-undo.nvim",
	event = "VeryLazy",
	opts = {
		hlgroup = "HighlightUndo",
		duration = 50,
		ignored_filetypes = { "neo-tree", "fugitive", "TelescopePrompt", "mason", "lazy" },
	},
}
