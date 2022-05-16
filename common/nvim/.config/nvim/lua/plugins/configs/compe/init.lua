require('cmp').setup {
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
    spell = false;
    tags = true;
    snippets_nvim = true;
    treesitter = true;
  };
}

--[[ -- silent, exprs noremap
map('i', '<C-n>',     'compe#complete()', { silent = true, expr = true, noremap = true })
map('i', '<CR>',      'compe#confirm()', { silent = true, expr = true, noremap = true })
map('i', '<C-e>',     'compe#close()', { silent = true, expr = true, noremap = true }) ]]

--[[ map('i', '<Tab>',     'pumvisible() ? "\<C-n>" : "\<Tab>"', { silent = true, expr = true, noremap = true })
map('i', '<S-Tab>',   'pumvisible() ? "\<C-p>" : "\<S-Tab>"', { silent = true, expr = true, noremap = true }) ]]

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

map("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
map('i', '<CR>',      'compe#confirm()', { silent = true, expr = true, noremap = true })
