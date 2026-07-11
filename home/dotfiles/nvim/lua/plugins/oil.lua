vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({ delete_to_trash = true })

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<cmd>Oil .<cr>", { desc = "Open root directory" })
