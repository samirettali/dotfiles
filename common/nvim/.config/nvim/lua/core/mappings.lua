local utils = require('core.utils')
local map = utils.map

vim.g.mapleader = ' '

-- Yank entire line except newline
map('n', 'Y', 'y$')

-- Keep text selected after intentating it
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Apply macros with Q
map('n', 'Q', '@q')
map('v', 'Q', ':norm @q<CR>') -- TODO needed?

-- Select last changed text
map ('n', 'gV', '`[v`]')

-- Splits
map('n', '\\', ':vsplit<CR>')
map('n', '-', ':split<CR>')

-- Duplicate paragraph
map('n', '<Leader>d', 'yap<S-}>p', { silent = true})

-- Go back to last selected file
map('n', '<Leader><Leader>', '<C-^>')

-- Toggle listchars
map('n', '<Leader>i', ':set list!<CR>', { silent = true })

-- Keep only the current window
map('n', '<Leader>o', ':only<CR>', { silent = true })

-- Load current buffer
map('n', '<Leader>l', ':luafile %<CR>', { silent = true })

-- Reload configs and sync plugins
map('n', '<Leader>l', ':luafile ~/.config/nvim/init.lua<CR> | :PackerSync<CR>', { silent = true })

-- Remove trailing whitespace
map('n', '<Leader>t', ':%s/\\s\\+$//e<CR>')

-- Paste replace visual selection without copying it
map('v', '<Leader>p', '"_dP"', { noremap = true })

map('n', '<Leader>k', 'gcip', { noremap = false })

map('v', '<C-c>', '"+y')

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

map('n', 'gR',         '<cmd>lua require("telescope.builtin").lsp_references()<CR>')
map('n', 'dn',         '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', 'dp',         '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', 'ds',         '<cmd>lua vim.diagnostic.get()<CR>')
map('n', '<Leader>gw', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
map('n', '<Leader>gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
map('n', '<Leader>=',  '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n', 'gu',         '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
map('n', '<Leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
map('n', '<Leader>fe', '<cmd>lua require("telescope.functions").diagnostics()<CR>')

map('n', 'cd',         '<cmd>lua vim.diagnostic.get()<CR>')
map('n', 'ga',         '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', 'rn',         '<cmd>lua vim.lsp.buf.rename()<CR>')

map('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', 'gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', 'gs',         '<cmd>lua vim.lsp.buf.signature_help()<CR>')

map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

