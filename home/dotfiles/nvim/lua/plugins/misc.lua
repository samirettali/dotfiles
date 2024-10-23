return {
	"tpope/vim-repeat", -- Repeat plugin mappings with .
	"tommcdo/vim-exchange", -- Exchange two objects
	"tpope/vim-eunuch", -- UNIX commands inside neovim
	"tpope/vim-surround", -- Add surround object for editing
	{ "echasnovski/mini.ai", config = true }, -- AI
	{ "norcalli/nvim-colorizer.lua", config = true }, -- Highlight colors
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
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		opts = {
			-- configurations go here
		},
	},
}
