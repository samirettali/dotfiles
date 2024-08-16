return {
	"tpope/vim-repeat", -- Repeat plugin mappings with .
	"tommcdo/vim-exchange", -- Exchange two objects
	"tpope/vim-eunuch", -- UNIX commands inside neovim, disabled because it broke something
	"tpope/vim-surround", -- Add surround object for editing
	"github/copilot.vim", -- Copilot
	{ "stevearc/dressing.nvim", config = true }, -- Floating UI selectors
	{ "j-hui/fidget.nvim", config = true }, -- Show LSP loading status
	{ "stevearc/oil.nvim", config = true }, -- File explorer
	{
		-- Hide secrets in .env files
		"laytan/cloak.nvim",
		config = function()
			vim.keymap.set("n", "<leader>tc", "<cmd>CloakToggle<cr>", { noremap = true, silent = true })
		end,
	},
}
