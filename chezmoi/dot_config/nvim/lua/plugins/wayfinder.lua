vim.pack.add({ "https://github.com/error311/wayfinder.nvim" })

require("wayfinder").setup({})

vim.keymap.set("n", "<leader>wf", "<Plug>(WayfinderOpen)", { desc = "Wayfinder" })
