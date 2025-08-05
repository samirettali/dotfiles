return {
	"tzachar/highlight-undo.nvim",
	event = "VeryLazy",
	opts = {
		hlgroup = "HighlightUndo",
		duration = 100,
		ignored_filetypes = { "neo-tree", "fugitive", "TelescopePrompt", "mason", "lazy" },
	},
}
