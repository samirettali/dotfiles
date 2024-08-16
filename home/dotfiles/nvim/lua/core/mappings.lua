vim.g.mapleader = " "

-- Keep text selected after indentating it
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Select last changed text
vim.keymap.set("n", "gV", "`[v`]")

vim.keymap.set("n", "<Leader>d", "yap<S-}>p", { desc = "Duplicate paragraph" })

vim.keymap.set("n", "<Leader>tl", ":set list!<CR>", { desc = "Toggle listchars" })

-- Remove trailing whitespace
-- map("n", "<Leader>t", ":%s/\\s\\+$//e<CR>")

vim.keymap.set("v", "<Leader>p", '"_dP"', { remap = false, desc = "Paste replace visual selection without copying it" })

-- Paste last yanked text
-- map("n", ",p", '"0p')
-- map("v", ",P", '"0P')

vim.keymap.set("v", "<C-c>", '"+y', { noremap = false, silent = true, desc = "Copy to clipboard" })

-- Keep lines centered when going through search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Center <C-o> and <C-i>
vim.keymap.set("n", "<C-o>", "<C-o>zzzv")
vim.keymap.set("n", "<C-i>", "<C-i>zzzv")

-- Mantain cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- map("n", "<C-j>", ":cnext<CR>zzzv")

-- Undo break points
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", "!", "!<C-g>u")
vim.keymap.set("i", "?", "?<C-g>u")
vim.keymap.set("i", "[", "[<C-g>u")
vim.keymap.set("i", "]", "]<C-g>u")

vim.keymap.set("n", "<C-p>", ":bp<CR>", { silent = true, desc = "Go to previous buffer" })
vim.keymap.set("n", "<C-n>", ":bn<CR>", { silent = true, desc = "Go to next buffer" })

vim.keymap.set("n", "<Tab>", ":tabnext<CR>", { silent = true, desc = "Go to next tab" })
vim.keymap.set("n", "<S-Tab>", ":tabp<CR>", { silent = true, desc = "Go to previous tab" })

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<space>", "<nop>", { silent = true })

-- Paste replacing selected text but without copying it
vim.keymap.set("x", "<leader>p", [["_dP]])

-- vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- FIXME: comment block and duplicate
vim.keymap.set("v", "<Leader>D", [[y`>pgv:norm gcc<CR>`>j^]], { silent = true })

vim.keymap.set("n", "<Leader>y", ":%y +<CR>", { noremap = false, silent = true, desc = "Copy entire buffer" })

-- zoom current split
vim.keymap.set("n", "<leader>z", "<C-w>o<C-w>|", { silent = true, desc = "Maximize current split" })

-- Resize splits
vim.keymap.set("n", "<M-,>", "<C-w>5<", { silent = true })
vim.keymap.set("n", "<M-.>", "<C-w>5>", { silent = true })
vim.keymap.set("n", "<M-t>", "<C-w>+", { silent = true })
vim.keymap.set("n", "<M-s>", "<C-w>-", { silent = true })
