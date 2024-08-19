vim.g.mapleader = " "

vim.keymap.set("n", "<Tab>", "<C-6>", { remap = true })

vim.keymap.set("n", "<Leader>d", "yap<S-}>p", { desc = "Duplicate paragraph" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste replace visual selection without copying it" })

vim.keymap.set("n", "gV", "`[v`]", { desc = "Select last changed text" })
vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Keep cursor position when joining lines" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Center next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Center previous search result" })
vim.keymap.set("n", "<C-o>", "<C-o>zzzv", { desc = "Center previous jump" })
vim.keymap.set("n", "<C-i>", "<C-i>zzzv", { desc = "Center next jump" })

-- map("n", "<C-j>", ":cnext<CR>zzzv")

vim.keymap.set("i", ",", ",<C-g>u", { desc = "Treat , as un undo breakpoint" })
vim.keymap.set("i", ".", ".<C-g>u", { desc = "Treat . as un undo breakpoint" })
vim.keymap.set("i", "!", "!<C-g>u", { desc = "Treat ! as un undo breakpoint" })
vim.keymap.set("i", "?", "?<C-g>u", { desc = "Treat ? as un undo breakpoint" })
vim.keymap.set("i", "[", "[<C-g>u", { desc = "Treat [ as un undo breakpoint" })
vim.keymap.set("i", "]", "]<C-g>u", { desc = "Treat ] as un undo breakpoint" })

vim.keymap.set("n", "<C-p>", ":bp<CR>", { desc = "Go to previous buffer", silent = true })
vim.keymap.set("n", "<C-n>", ":bn<CR>", { desc = "Go to next buffer", silent = true })

vim.keymap.set({ "n", "v" }, "<space>", "<nop>", { desc = "Disable space", silent = true })
vim.keymap.set({ "n", "v" }, "<del>", "<nop>", { desc = "Disable space", silent = true })

-- Resize splits
vim.keymap.set("n", "<M-,>", "<C-w>5<", { silent = true })
vim.keymap.set("n", "<M-.>", "<C-w>5>", { silent = true })
vim.keymap.set("n", "<M-t>", "<C-w>+", { silent = true })
vim.keymap.set("n", "<M-s>", "<C-w>-", { silent = true })

-- Old stuff

-- Keep text selected after indentating it
-- vim.keymap.set("v", "<", "<gv")
-- vim.keymap.set("v", ">", ">gv")

-- Keep cursor centered when scrolling
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
