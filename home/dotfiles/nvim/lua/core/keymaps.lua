local utils = require("core.utils")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>tl", "<CMD>set list!<CR>", { desc = "Toggle listchars" })
vim.keymap.set("n", "<Leader>tc", "<CMD>set cursorline!<CR>", { desc = "Toggle cursorline" })

vim.keymap.set("n", "<localleader>q", utils.toggle_quickfix, { desc = "Toggle quickfix window" })

vim.keymap.set("n", "<localleader>c", utils.delete_hidden_buffers, { desc = "Close hidden buffers" })

vim.keymap.set({ "i", "n" }, "<esc>", "<CMD>noh<CR><esc>", { desc = "Clear hlsearch and ESC" })

-- TODO: overrides default behaviour
-- vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search within visual selection" })
-- vim.keymap.set("n", "J", "mzJ`z:delmarks z<CR>", { desc = "Keep cursor in place when joining lines" })

-- TODO: make it an operator
-- vim.keymap.set({ "n", "x" }, "yc", function()
-- 	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
-- 	return "g@"
-- end, { expr = true, desc = "Duplicate selection and comment out the first instance" })

-- vim.keymap.set("n", "ycc", function()
-- 	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
-- 	return "g@_"
-- end, { expr = true, desc = "Duplicate [count] lines and comment out the first instance" })

vim.keymap.set({ "n", "v" }, "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd('normal! "_dd')
	else
		vim.cmd("normal! dd")
	end
end, { desc = "Delete a line and copy it only if it's not empty", silent = true })

vim.keymap.set("n", "<localleader>r", "<CMD>restart<CR>", { desc = "Restart" })
