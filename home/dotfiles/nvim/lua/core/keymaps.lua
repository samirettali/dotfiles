local utils = require("core.utils")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })
vim.keymap.set("n", "<localleader>q", utils.toggle_quickfix, { desc = "Toggle quickfix window" })

-- vim.keymap.set("n", "gV", "`[v`]", { desc = "Select last changed text" })
vim.keymap.set("n", "<localleader>r", ":restart<CR>", { desc = "Restart Neovim", silent = true })

vim.keymap.set("o", "V", "`[v`]", { desc = "Select last changed text" })

vim.keymap.set({ "n", "v" }, "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd('normal! "_dd')
	else
		vim.cmd("normal! dd")
	end
end, { desc = "Delete a line and copy it only if it's not empty", silent = true })

vim.keymap.set("n", "<leader>ha", utils.toggle_line_highlight, { desc = "Toggle highlight line" })
vim.keymap.set("n", "<leader>hr", "<cmd>call clearmatches()<CR>", { desc = "Clear highlighted lines" })

vim.keymap.set("n", "<localleader>c", utils.delete_hidden_buffers, { desc = "Close hidden buffers" })

-- TODO: overrides gp
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select pasted text" })

vim.keymap.set({ "n", "x" }, "yc", function()
	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
	return "g@"
end, { expr = true, desc = "Duplicate selection and comment out the first instance" })

vim.keymap.set("n", "ycc", function()
	vim.opt.operatorfunc = [[v:lua.require("core.utils").duplicate_and_comment_lines]]
	return "g@_"
end, { expr = true, desc = "Duplicate [count] lines and comment out the first instance" })

-- TODO: overrides default behaviour
vim.keymap.set("x", "/", "<Esc>/\\%V", { desc = "Search within visual selection" })
vim.keymap.set("n", "J", "mzJ`z:delmarks z<cr>", { desc = "Keep cursor in place when joining lines" })

vim.keymap.set("n", "d{", "V{jd", { desc = "Delete until the start of the paragraph" })
vim.keymap.set("n", "d}", "V}kd", { desc = "Delete until the end of the paragraph" })

vim.keymap.set(
	"v",
	"<leader>_",
	":<C-U>keeppatterns '<,'>s/\\%V[ -]/_/g<CR>",
	{ desc = "Replace all spaces in selected region with _" }
)

vim.keymap.set("x", "R", ":s###g<left><left><left>", { desc = "Start replacement in the visual selected region" })
