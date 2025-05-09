vim.g.mapleader = " "

vim.keymap.set("n", "<Tab>", "<C-6>", { remap = true })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without copying" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without copying" })

vim.keymap.set("n", "<Leader>dp", "yip<S-}>p", { desc = "Duplicate paragraph" })

vim.keymap.set("n", "<Leader>c", "ggVGy<C-o>", { desc = "Copy entire file", silent = true })

vim.keymap.set("n", "gV", "`[v`]", { desc = "Select last changed text" })
vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Keep cursor position when joining lines" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })
vim.keymap.set("n", "<C-o>", "<C-o>zzzv", { desc = "Center previous jump" })
vim.keymap.set("n", "<C-i>", "<C-i>zzzv", { desc = "Center next jump" })

vim.keymap.set("i", ",", ",<C-g>u", { desc = "Treat , as un undo breakpoint" })
vim.keymap.set("i", ".", ".<C-g>u", { desc = "Treat . as un undo breakpoint" })
vim.keymap.set("i", "!", "!<C-g>u", { desc = "Treat ! as un undo breakpoint" })
vim.keymap.set("i", "?", "?<C-g>u", { desc = "Treat ? as un undo breakpoint" })
vim.keymap.set("i", "[", "[<C-g>u", { desc = "Treat [ as un undo breakpoint" })
vim.keymap.set("i", "]", "]<C-g>u", { desc = "Treat ] as un undo breakpoint" })

vim.keymap.set("n", "<C-p>", ":bp<CR>", { desc = "Go to previous buffer", silent = true })
vim.keymap.set("n", "<C-n>", ":bn<CR>", { desc = "Go to next buffer", silent = true })

vim.keymap.set("n", "tn", ":tabnext<CR>", { desc = "Go to next tab", silent = true })
vim.keymap.set("n", "tp", ":tabprevious<CR>", { desc = "Go to previous tab", silent = true })
vim.keymap.set("n", "to", ":tabnew<CR>", { desc = "Go to new tab", silent = true })
vim.keymap.set("n", "tc", ":tabclose<CR>", { desc = "Close current tab", silent = true })

vim.keymap.set({ "n", "v" }, "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd('normal! "_dd')
	else
		vim.cmd("normal! dd")
	end
end, { desc = "Delete a line and copy it only if it's not empty", silent = true })

vim.keymap.set({ "n", "v" }, "yy", function()
	if not vim.api.nvim_get_current_line():match("^%s*$") then
		vim.cmd("normal! yy")
	end
end, { desc = "Yank only if the line is not empty", silent = true })

-- Old stuff

-- Keep text selected after indentating it
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Keep cursor centered when scrolling
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
