local function copy_file_content()
	vim.cmd("silent 1,$y +")
	local line_count = vim.fn.line("$")
	vim.notify("Copied " .. line_count .. " lines", vim.log.levels.INFO)
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<bs>", "<C-6>", { remap = true })

vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without copying" })

-- TODO: fix
-- vim.keymap.set("n", "<Leader>dp", "yip<S-}>po<escape>k", { desc = "Duplicate paragraph" })

vim.keymap.set("n", "<Leader>y", copy_file_content, { desc = "Copy file content", silent = true })

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

vim.keymap.set("n", "<tab>", ":tabnext<CR>", { desc = "Go to next tab", silent = true })
vim.keymap.set("n", "<s-tab>", ":tabprevious<CR>", { desc = "Go to previous tab", silent = true })
vim.keymap.set("n", "tn", ":tabnew<CR>", { desc = "Go to new tab", silent = true })
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
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- TODO
local function toggle_quickfix()
	local windows = vim.fn.getwininfo()

	for _, win in pairs(windows) do
		if win["quickfix"] == 1 then
			vim.cmd.cclose()
			return
		end
	end

	vim.cmd.copen()
end

vim.keymap.set("n", "<localleader>q", toggle_quickfix, { desc = "Toggle Quickfix Window" })
