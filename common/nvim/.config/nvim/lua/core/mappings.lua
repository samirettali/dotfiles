local utils = require('core.utils')
local map = utils.map

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
map('n', '<Leader>i', ':set list!<CR>')

-- Keep only the current window
map('n', '<Leader>o', ':only<CR>')

-- Load current buffer
map('n', '<Leader>l', ':luafile %<CR>')

-- Reload configs and sync plugins
map('n', '<Leader>l', ':luafile ~/.config/nvim/init.lua<CR> | :PackerSync<CR>')

-- Remove trailing whitespace
map('n', '<Leader>t', ':%s/\\s\\+$//e<CR>')

-- Paste replace visual selection without copying it
map('v', '<Leader>p', '"_dP"', { noremap = true })

map('n', '<Leader>k', 'gcip', { noremap = false })

map('n', '<C-i>', '<C-a>', { noremap = false })

-- Join with above line
-- map('n', 'K', 'kJ')

-- Keep lines centered when searching
map('n', 'n', 'nzzzv')
map('n', 'N', 'nzzzv')
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

map('n', 'dn', function() vim.diagnostic.goto_next() end)
map('n', 'dp', function() vim.diagnostic.goto_prev() end)
map('n', 'ds', function() vim.diagnostic.get() end)
map('n', '<Leader>gw', function() vim.lsp.buf.document_symbol() end)
map('n', '<Leader>gW', function() vim.lsp.buf.workspace_symbol() end)
map('n', '<Leader>=', function() vim.lsp.buf.formatting() end)
map('n', 'gu', function() vim.lsp.buf.incoming_calls() end)
map('n', '<Leader>ao', function() vim.lsp.buf.outgoing_calls() end)
map('n', '<Leader>fe', function() require("telescope.functions").diagnostics() end)

map('n', 'cd', function() vim.diagnostic.get() end)
map('n', 'ga', function() vim.lsp.buf.code_action() end)
map('n', 'rn', function() vim.lsp.buf.rename() end)

map('n', 'K', function() vim.lsp.buf.hover() end)
map('n', 'gd', function() vim.lsp.buf.definition() end)
map('n', 'gD', function() vim.lsp.buf.declaration() end)
map('n', 'gi', function() vim.lsp.buf.implementation() end)
map('n', 'gs', function() vim.lsp.buf.signature_help() end)

map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Close buffer
map("n", "<C-q>", ":bd<CR>")

-- Plugins
-- Telescope
map("n", "<C-f>", "<Cmd>Telescope find_files<CR>")
-- map("n", "<C-q>", "<Cmd>Telescope lsp_workspace_diagnostics<CR>")
map("n", "<C-s>", "<Cmd>Telescope lsp_document_symbols<CR>")
-- map("n", "<C-w>", "<Cmd>Telescope lsp_workspace_symbols<CR>")
map("n", "<C-b>", "<Cmd>Telescope buffers<CR>")
map("n", "<C-g>", "<Cmd>Telescope live_grep<CR>")

map("n", "<Leader>fR", "<Cmd>lua require('telescope.builtin')['lsp_references']()<CR>", { noremap = true, silent = true })
map("n", "<Leader>fS", "<Cmd>lua require('telescope.builtin')['lsp_document_symbols']()<CR>",
    { noremap = true, silent = true })
map("n", "<Leader>fs", "<Cmd>lua require('telescope.builtin')['lsp_workspace_symbols']()<CR>",
    { noremap = true, silent = true })
map("n", "<Leader>fd", "<Cmd>lua require('telescope.builtin')['lsp_workspace_diagnostics']()<CR>",
    { noremap = true, silent = true })

-- Load current buffer into Neovim
map("n", "<Leader><Leader>x", "<Cmd>source %<CR>", { noremap = true })
map("n", "<Leader><Leader>p", "<Cmd>PackerSync<CR>", { noremap = true })

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

-- nvim-tree
map("n", "<C-t>", "<cmd>NvimTreeToggle<CR>")

-- BufferLine
map("n", "<C-p>", ":BufferPrevious<CR>", { silent = true })
map("n", "<C-n>", ":BufferNext<CR>", { silent = true })
map("n", "<Leader>p", ":BufferMovePrevious<CR>", { silent = true })
map("n", "<Leader>n", ":BufferMoveNext<CR>", { silent = true })

map("n", "<Leader>gm", "<Plug>(git-messenger)")
