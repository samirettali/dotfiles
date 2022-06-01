local tabby = require('tabby')
local options = {
    tabline = require('tabby.presets').active_tab_with_wins,
}

tabby.setup(options)

vim.api.nvim_set_keymap("n", "<C-n>", ":bn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-p>", ":bp<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true })
