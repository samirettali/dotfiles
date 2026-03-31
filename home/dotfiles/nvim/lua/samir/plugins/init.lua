require("samir.plugins.snacks")
require("samir.plugins.persistence")
require("samir.plugins.quicker")
require("samir.plugins.obsidian")
require("samir.plugins.redraft")
require("samir.plugins.dap")
require("samir.plugins.actions-preview")
require("samir.plugins.split")
require("samir.plugins.codediff")
require("samir.plugins.csvview")

vim.pack.add({
	"https://github.com/vague2k/vague.nvim",
	"https://github.com/WTFox/jellybeans.nvim",
	"https://github.com/projekt0n/github-nvim-theme",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/sainnhe/everforest",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/NAlexPear/Spacegray.nvim",
	"https://github.com/smit4k/shale.nvim",
})

require("vague").setup({
	transparent = false,
	-- Disable bold/italic globally
	bold = true,
	italic = false,
})

vim.pack.add({
	"https://github.com/Sang-it/fluoride",
})
require("fluoride").setup()

vim.keymap.set("n", "<leader>cp", "<cmd>Fluoride<cr>", { desc = "Fluoride" })
