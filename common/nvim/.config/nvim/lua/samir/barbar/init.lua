vim.g.bufferline = {
  icons = true,
  closable = true,
  clickable = true,
  maximum_padding = 1,
  animation = false,
}

map('n', '<C-s>',     ':BufferPick<CR>',     { silent = true })
map('n', '<C-n>',     ':BufferNext<CR>',     { silent = true })
map('n', '<C-p>',     ':BufferPrev<CR>',     { silent = true })
map('n', '<C-w>',     ':BufferClose<CR>',    { silent = true })
map('n', '<M-Right>', ':BufferMoveNext<CR>', { silent = true })
map('n', '<M-Left>',  ':BufferMovePrev<CR>', { silent = true })
