vim.g.mapleader = ','

-- Yank entire line except newline
map('n', 'Y', 'y$')

-- Copy and paste using system clipboard
-- map('v', '<C-c>', '"+y') map('v', '<C-x>', '"+d')

-- Keep text selected after intentating it
map('v', '<', '<gv')
map('v', '>', '>gv')


-- Apply macros with Q
map('n', 'Q', '@q')
-- TODO needed?
map('v', 'Q', ':norm @q<CR>')

-- Select text inserted during last insert mode usage
map ('n', 'gV', '`[v`]')

-- Splits
map('n', '\\', ':vsplit<CR>')
map('n', '-', ':split<CR>')
map('n', '\\|', ':vsplit')
map('n', '_', ':split')

-- Duplicate paragraph
map('n', '<Leader>d', 'yap<S-}>p')

-- Go back to last selected file
map('n', '<Leader><Leader>', '<C-^>')

-- Toggle listchars
map('n', '<Leader>i', ':set list!<CR>', { silent = true })

-- Toggle colorcolumn
-- TODO let or set?
map('n', '<Leader>cc', ':let &cc = &cc == "" ? 81 : ""<CR>', { silent = true })

map('n', '<Leader>o', ':only<CR>', { silent = true })

-- Load current buffer
map('n', '<Leader>l', ':luafile %<CR>', { silent = true })

-- Sync plugins
map('n', '<Leader>ps', ':PackerSync<CR>', { silent = true })

-- map('n', '<Leader>t', ':%s/\s\+$//e<CR>')
