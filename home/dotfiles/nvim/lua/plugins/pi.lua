vim.pack.add({ "https://github.com/pablopunk/pi.nvim" })

require("pi").setup()

vim.keymap.set("n", "<leader>ai", ":PiAsk<CR>", { desc = "Ask pi" })
vim.keymap.set("v", "<leader>ai", ":PiAskSelection<CR>", { desc = "Ask pi (selection)" })
