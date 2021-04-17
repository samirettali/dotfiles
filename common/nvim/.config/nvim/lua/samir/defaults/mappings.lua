vim.g.mapleader = ' '

-- Yank entire line except newline
map('n', 'Y', 'y$')

-- Keep text selected after intentating it
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Apply macros with Q
map('n', 'Q', '@q')
map('v', 'Q', ':norm @q<CR>') -- TODO needed?

-- Select text inserted during last insert mode usage
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

-- Toggle colorcolumn
map('n', '<Leader>cc', ':let &cc = &cc == "" ? 81 : ""<CR>', { silent = true })

-- Keep only the current window
map('n', '<Leader>o', ':only<CR>', { silent = true })

-- Load current buffer
map('n', '<Leader>l', ':luafile %<CR>', { silent = true })

-- Sync plugins
map('n', '<Leader>ps', ':PackerSync<CR>', { silent = true })

-- Remove trailing whitespace
map('n', '<Leader>t', ':%s/\\s\\+$//e<CR>')

-- Paste replace visual selection without copying it
map('v', '<Leader>p', '"_dP"', { noremap = true })
