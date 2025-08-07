return {
	"echasnovski/mini.extra",
	event = "VeryLazy",
	opts = {},
	dependencies = { "echasnovski/mini.pick" },
	keys = {
		{
			"<leader>fc",
			"<cmd>Pick commands<cr>",
			{ desc = "Pick commands" },
		},
		{
			"<leader>fd",
			"<cmd>Pick diagnostic<cr>",
			"n",
			{ desc = "Pick diagnostics" },
		},
		{
			"<leader>fk",
			"<cmd>Pick keymaps<cr>",
			"n",
			{ desc = "Pick keymaps" },
		},
		{
			"<leader>fl",
			"<cmd>Pick buf_lines<cr>",
			"n",
			{ desc = "Pick lines" },
		},
		{
			"<leader>fm",
			"<cmd>Pick marks<cr>",
			"n",
			{ desc = "Pick marks" },
		},
		{
			"<leader>fo",
			"<cmd>Pick options<cr>",
			"n",
			{ desc = "Pick options" },
		},
		{
			"<leader>fq",
			"<cmd>Pick list scope='quickfix'<cr>",
			{ desc = "Pick quickfix" },
		},
		{
			"<leader>fs",
			"<cmd>lua require('mini.extra').pickers.lsp({ scope = 'document_symbol' })<cr>",
			{ desc = "Pick lsp document symbol", silent = true },
		},
	},
}
