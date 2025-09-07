return {
	"echasnovski/mini.extra",
	event = "VeryLazy",
	version = false,
	opts = {},
	dependencies = { "echasnovski/mini.pick" },
	keys = {
		{
			"<leader>fc",
			"<CMD>Pick commands<CR>",
			desc = "Pick commands",
		},
		{
			"<leader>fd",
			"<CMD>Pick diagnostic<CR>",
			desc = "Pick diagnostics",
		},
		{
			"<leader>fk",
			"<CMD>Pick keymaps<CR>",
			desc = "Pick keymaps",
		},
		{
			"<leader>fl",
			"<CMD>Pick buf_lines scope='current'<CR>",
			desc = "Pick lines",
		},
		{
			"<leader>fm",
			"<CMD>Pick marks<CR>",
			desc = "Pick marks",
		},
		{
			"<leader>fo",
			"<CMD>Pick options<CR>",
			desc = "Pick options",
		},
		{
			"<leader>fq",
			"<CMD>Pick list scope='quickfix'<CR>",
			desc = "Pick quickfix",
		},
		{
			"<leader>fe",
			"<CMD>Pick explorer<CR>",
			desc = "Pick quickfix",
		},
		{
			"<leader>fs",
			"<CMD>lua require('mini.extra').pickers.lsp({ scope = 'document_symbol' })<CR>",
			desc = "Pick lsp document symbol",
		},
		{
			"<leader>fw",
			function()
				local scope = vim.fn.input("Query: ", "")
				require("mini.extra").pickers.lsp({ scope = "workspace_symbol", symbol_query = scope })
			end,
			desc = "Pick lsp document symbol",
		},
	},
}
