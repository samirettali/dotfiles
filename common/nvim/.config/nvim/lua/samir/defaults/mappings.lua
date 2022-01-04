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
map('i', '{', '{<C-g>u')
map('i', '{', '}<C-g>u')

-- Shift selected lines
map('v', 'J', ":m '>+1<cr>gv=gv")
map('v', 'K', ":m '<-2<cr>gv=gv")
