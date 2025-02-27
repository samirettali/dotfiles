return {
	"tpope/vim-repeat", -- Repeat plugin mappings with .
	"tommcdo/vim-exchange", -- Exchange two objects
	"tpope/vim-eunuch", -- UNIX commands inside neovim
	"tpope/vim-surround", -- Add surround object for editing
	{ "echasnovski/mini.ai", config = true }, -- AI
	{ "stevearc/oil.nvim", config = true }, -- File manager
	{
		"mawkler/refjump.nvim",
		-- keys = { "]r", "[r" }, -- Uncomment to lazy load
		opts = {},
	},
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			local colorizer = require("colorizer")
			colorizer.setup()
			vim.keymap.set("n", "<leader>th", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })
		end,
	},
	{
		"seblj/roslyn.nvim",
		ft = "cs",
		opts = {
			exe = "Microsoft.CodeAnalysis.LanguageServer",
		},
	},
	-- { "saecki/live-rename.nvim", },
}
