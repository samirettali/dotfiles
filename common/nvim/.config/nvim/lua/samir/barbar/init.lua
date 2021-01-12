vim.g.bufferline = {
  icons = false,
  closable = false,
  clickable = false,
  maximum_padding = 0,
  animation = false,
}

map('n', '<C-s>', ':BufferPick<CR>', { silent = true })
map('n', '<C-n>', ':BufferNext<CR>', { silent = true })
map('n', '<C-p>', ':BufferPrev<CR>', { silent = true })
map('n', '<C-w>', ':BufferClose<CR>', { silent = true })
map('n', '<M-Right>', ':BufferMoveNext<CR>', { silent = true })
map('n', '<M-Left>', ':BufferMovePrev<CR>', { silent = true })

-- require'bufferline'.setup{
--   options = {
--     view = "default",
--     numbers = "none",
--     -- number_style = "",
--     -- mappings = true,
--     -- buffer_close_icon= '',
--     -- modified_icon = '●',
--     -- close_icon = '',
--     -- left_trunc_marker = '',
--     -- right_trunc_marker = '',
--     -- max_name_length = 18,
--     -- max_prefix_length = 15, -- prefix used when a buffer is deduplicated
--     -- tab_size = 18,
--     show_buffer_close_icons = true,
--     -- persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
--     -- -- can also be a table containing 2 custom separators
--     -- -- [focused and unfocused]. eg: { '|', '|' }
--     -- separator_style = "slant",
--     -- enforce_regular_tabs = true,
--     always_show_bufferline = true,
--     -- sort_by = 'extension'
--   }
-- }

-- map('n', '<C-n>', ':BufferLineCycleNext<CR>', { silent = true })
-- map('n', '<C-p>', ':BufferLineCyclePrev<CR>', { silent = true })
-- map('n', '<M-Right>', ':BufferLineMoveNext<CR>', { silent = true })
-- map('n', '<M-Left>', ':BufferLineMovePrev<CR>', { silent = true })
