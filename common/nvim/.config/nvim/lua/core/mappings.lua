local utils = require('core.utils')
local map = utils.map
local telescope_map = utils.telescope_map

vim.g.mapleader = ' '

-- Core mappings
-- Yank entire line except newline
map('n', 'Y', 'y$')

-- Keep text selected after intentating it
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Apply macros with Q
map('n', 'Q', '@q')
map('v', 'Q', ':norm @q<CR>') -- TODO needed?

-- Select last changed text
map('n', 'gV', '`[v`]')

-- Splits
map('n', '\\', ':vsplit<CR>')
map('n', '-', ':split<CR>')

-- Duplicate paragraph
map('n', '<Leader>d', 'yap<S-}>p')

-- Go back to last selected file
map('n', '<Leader><Leader>', '<C-^>')

-- Toggle listchars
map('n', '<Leader>l', ':set list!<CR>')

-- Keep only the current window
map('n', '<Leader>o', ':only<CR>')

-- Remove trailing whitespace
-- map('n', '<Leader>t', ':%s/\\s\\+$//e<CR>')

map('v', '<Leader>p', '"_dP"', {
    remap = false,
    desc = "Paste replace visual selection without copying it"
})

map('n', '<Leader>k', 'gcip', { remap = true })

-- Increment number under cursor
map('n', '<Leader>i', '<C-a>', { remap = true })

-- Join with above line
-- map('n', 'K', 'kJ')

-- Map ; to : in normal and visual mode
map("n", ";", ":")
map("v", ";", ":")

-- Paste last yanked text
map("n", ",p", '"0p')
map("v", ",P", '"0P')

-- Keep lines centered when searching
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', 'J', 'mzJ`z')
map('n', '<C-j>', ':cnext<CR>zzzv')

-- Undo break points
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', '!', '!<C-g>u')
map('i', '?', '?<C-g>u')
map('i', '[', '[<C-g>u')
map('i', ']', ']<C-g>u')

map('n', 'gR', function()
    require("telescope.builtin").lsp_references()
end)

-- Close buffer
map("n", "<C-q>", ":bd<CR>")

-- Plugins
-- Telescope
map("n", "<C-f>", "<Cmd>Telescope find_files hidden=false<CR>")
-- map("n", "<C-q>", "<Cmd>Telescope lsp_workspace_diagnostics<CR>")
map("n", "<C-s>", "<Cmd>Telescope lsp_document_symbols<CR>")
map("n", "<C-w>", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>")
map("n", "<C-b>", "<Cmd>Telescope buffers<CR>")
map("n", "<C-g>", "<Cmd>Telescope live_grep<CR>")

telescope_map("<Leader>fR", "lsp_references")
telescope_map("<Leader>fS", "lsp_document_symbols")
telescope_map("<Leader>fs", "lsp_workspace_symbols")
telescope_map("<Leader>fd", "lsp_workspace_diagnostics")

-- Scalpel
map("n", "<Leader>s", "<Plug>(Scalpel)", { remap = false })

-- Trouble
map("n", "<leader>xx", "<Cmd>LspTroubleToggle<cr>")
map("n", "<leader>xw", "<Cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>")
map("n", "<leader>xd", "<Cmd>LspTroubleToggle lsp_document_diagnostics<cr>")
map("n", "<leader>xq", "<Cmd>LspTroubleToggle quickfix<cr>")
map("n", "<leader>xl", "<Cmd>LspTroubleToggle loclist<cr>")
map("n", "<leader>xr", "<Cmd>LspTroubleToggle lsp_references<cr>")

-- Splitline
map("n", "S", "<Cmd>SplitLine<CR>", { remap = true })

-- OSCYank
-- map("v", "<C-c>", ":OSCYank<CR>")
map("v", "<C-c>", '"+y')

-- -- nvim-tree
map("n", "<C-t>", "<cmd>NvimTreeToggle<CR>")

-- buffer moving
map("n", "<C-p>", ":bp<CR>", { silent = true })
map("n", "<C-n>", ":bn<CR>", { silent = true })

map("n", "<Leader>gm", "<Plug>(git-messenger)")

map("n", "g<", "<Cmd>ISwapNodeWithLeft<CR>")
map("n", "g>", "<Cmd>ISwapNodeWithRight<CR>")
map("n", "gs", "<Cmd>ISwap<CR>")

map("n", "<BS>", ":w ++p<CR>")
