require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'always';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    calc = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    snippets_nvim = true;
    treesitter = true;
  };
}

-- silent, exprs noremap
map('i', '<C-n>',     'compe#complete()', { silent = true, expr = true, noremap = true })
map('i', '<CR>',      'compe#confirm()', { silent = true, expr = true, noremap = true })
map('i', '<C-e>',     'compe#close()', { silent = true, expr = true, noremap = true })

--[[ map('i', '<Tab>',     'pumvisible() ? "\<C-n>" : "\<Tab>"', { silent = true, expr = true, noremap = true })
map('i', '<S-Tab>',   'pumvisible() ? "\<C-p>" : "\<S-Tab>"', { silent = true, expr = true, noremap = true }) ]]
