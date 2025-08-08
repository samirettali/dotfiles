local utils = require("core.utils")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })
vim.keymap.set("n", "<Leader>tc", ":set cursorline!<CR>", { desc = "Toggle cursorline" })

vim.keymap.set("n", "<localleader>q", utils.toggle_quickfix, { desc = "Toggle quickfix window" })

vim.keymap.set({ "n", "v" }, "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd('normal! "_dd')
	else
		vim.cmd("normal! dd")
	end
end, { desc = "Delete a line and copy it only if it's not empty", silent = true })

vim.keymap.set("n", "<localleader>c", utils.delete_hidden_buffers, { desc = "Close hidden buffers" })

vim.keymap.set({ "n", "x" }, "yc", function()
	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
	return "g@"
end, { expr = true, desc = "Duplicate selection and comment out the first instance" })

vim.keymap.set("n", "ycc", function()
	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
	return "g@_"
end, { expr = true, desc = "Duplicate [count] lines and comment out the first instance" })

-- TODO: overrides default behaviour
-- vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search within visual selection" })
-- vim.keymap.set("n", "J", "mzJ`z:delmarks z<cr>", { desc = "Keep cursor in place when joining lines" })

vim.keymap.set("x", "R", ":s###g<left><left><left>", { desc = "Start replacement in the visual selected region" })

vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })

vim.keymap.set("n", "<localleader>s", ":source %<CR>", { noremap = true, silent = true, desc = "Source current file" })
vim.keymap.set("n", "tn", ":tabnew<CR>", { noremap = true, silent = true, desc = "Open new tab" })
