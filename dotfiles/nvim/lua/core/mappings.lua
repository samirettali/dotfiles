local utils = require("core.utils")
local map = utils.map

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Core mappings
-- Yank entire line except newline
map("n", "Y", "y$")

-- Keep text selected after indentating it
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Apply macros with Q
map("n", "Q", "@q")
map("v", "Q", ":norm @q<CR>") -- TODO needed?

-- Select last changed text
map("n", "gV", "`[v`]")

-- Splits
map("n", "\\", ":vsplit<CR>")
map("n", "-", ":split<CR>")

map("n", "<Leader>d", "yap<S-}>p", { desc = "Duplicate paragraph" })

map("n", "<Leader>l", ":set list!<CR>", { desc = "Toggle listchars" })

map("n", "<Leader>o", ":only<CR>", { desc = "Make current window the only one" })

-- Remove trailing whitespace
-- map("n", "<Leader>t", ":%s/\\s\\+$//e<CR>")

map("v", "<Leader>p", '"_dP"', { remap = false, desc = "Paste replace visual selection without copying it" })

-- Increment and decrement number under cursor
vim.keymap.set("n", "<C-;>", "<C-a>")
vim.keymap.set("n", "<C-'>", "<C-x>")

-- Map ; to : in normal and visual mode
map("n", ";", ":")
map("v", ";", ":")

-- Paste last yanked text
map("n", ",p", '"0p')
map("v", ",P", '"0P')

-- Keep lines centered when searching
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Mantain cursor position when joining lines
map("n", "J", "mzJ`z")

-- map("n", "<C-j>", ":cnext<CR>zzzv")

-- Undo break points
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", "!", "!<C-g>u")
map("i", "?", "?<C-g>u")
map("i", "[", "[<C-g>u")
map("i", "]", "]<C-g>u")

map("n", "<C-p>", ":bp<CR>", { silent = true, desc = "Go to previous buffer" })
map("n", "<C-n>", ":bn<CR>", { silent = true, desc = "Go to next buffer" })

map("n", "<BS>", ":w ++p<CR>", { desc = "Save file and create parent folders" })

map("n", "<Tab>", "<C-^>", { desc = "Switch to last focused buffer" })

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({ "n", "v" }, "<space>", "<nop>", { silent = true })

-- Paste replacing selected text but without copying it
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Scalpel alternative
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])