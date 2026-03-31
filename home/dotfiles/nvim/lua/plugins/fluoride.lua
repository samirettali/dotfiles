vim.pack.add({
	"https://github.com/Sang-it/fluoride",
})

require("fluoride").setup()

vim.keymap.set("n", "<leader>cp", "<cmd>Fluoride<cr>", { desc = "Fluoride" })
