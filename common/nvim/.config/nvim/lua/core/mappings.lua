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
map('n', '<Leader>t', ':%s/\\s\\+$//e<CR>')

-- Paste replace visual selection without copying it
map('v', '<Leader>p', '"_dP"', { noremap = true })

map('n', '<Leader>k', 'gcip', { noremap = false })

-- Increment number under cursor
map('n', '<Leader>i', '<C-a>', { noremap = false })

-- Join with above line
-- map('n', 'K', 'kJ')

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

-- Shift selected lines
map('v', 'J', [[:m '>+1<cr>gv=gv]])
map('v', 'K', [[:m '<-2<cr>gv=gv]])
-- map("n", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true })
-- map("n", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true })

map('n', 'gR', function()
    require("telescope.builtin").lsp_references()
end)

-- map('n', 'ds', vim.diagnostic.get)
-- map('n', 'dn', vim.diagnostic.goto_next)
-- map('n', 'dp', vim.diagnostic.goto_prev)
-- map('n', 'dp', vim.diagnostic.goto_prev)
--
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'gT', vim.lsp.buf.type_definition)
map('n', 'K', vim.lsp.buf.hover)
map('n', 'ga', vim.lsp.buf.code_action)
map('n', 'gr', vim.lsp.buf.rename)

map('n', 'gs', vim.lsp.buf.document_symbol)
map('n', 'gS', vim.lsp.buf.workspace_symbol)
map('n', 'gi', vim.lsp.buf.incoming_calls)
-- map('n', '<Leader>ao', vim.lsp.buf.outgoing_calls)
-- map('n', '<Leader>fe', function() require("telescope.functions").diagnostics() end)

-- map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
-- map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

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
map("n", "<Leader>s", "<Plug>(Scalpel)", { noremap = false })

-- Trouble
map("n", "<leader>xx", "<Cmd>LspTroubleToggle<cr>")
map("n", "<leader>xw", "<Cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>")
map("n", "<leader>xd", "<Cmd>LspTroubleToggle lsp_document_diagnostics<cr>")
map("n", "<leader>xq", "<Cmd>LspTroubleToggle quickfix<cr>")
map("n", "<leader>xl", "<Cmd>LspTroubleToggle loclist<cr>")
map("n", "<leader>xr", "<Cmd>LspTroubleToggle lsp_references<cr>")

-- Splitline
map("n", "S", "<Cmd>SplitLine<CR>", { noremap = true })

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
