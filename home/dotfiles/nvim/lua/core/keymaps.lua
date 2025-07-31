local utils = require("core.utils")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })
vim.keymap.set("n", "<localleader>q", utils.toggle_quickfix, { desc = "Toggle quickfix window" })

vim.keymap.set("n", "<Leader>y", ":1,$y +<CR>", { desc = "Copy file content", silent = true })
-- vim.keymap.set("n", "gV", "`[v`]", { desc = "Select last changed text" })
vim.keymap.set("n", "<localleader>r", "restart<CR> ", { desc = "Restart Neovim", silent = true })

vim.keymap.set("o", "V", "`[v`]", { desc = "Select last changed text" })

vim.keymap.set({ "n", "v" }, "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd('normal! "_dd')
	else
		vim.cmd("normal! dd")
	end
end, { desc = "Delete a line and copy it only if it's not empty", silent = true })
