require('gitsigns').setup {

  signs = {
    add          = {hl = 'SignifySignAdd'   , text = '+', numhl='GitSignsAddNr'},
    change       = {hl = 'SignifySignChange', text = '~', numhl='GitSignsChangeNr'},
    delete       = {hl = 'SignifySignDelete', text = '-', numhl='GitSignsDeleteNr'},
    topdelete    = {hl = 'SignifySignChange', text = '‾', numhl='GitSignsDeleteNr'},
    changedelete = {hl = 'SignifySignChange', text = '~', numhl='GitSignsChangeNr'},
  },
  numhl = false,
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,

    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
  },
  watch_index = {
    interval = 1000
  },
  sign_priority = 6,
  status_formatter = nil, -- Use default
}
