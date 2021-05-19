require'colorizer'.setup({
    'css';
    'javascript';
    css = { css = true };
    html = { css = true };
})

map('n', '<Leader>c', ':ColorizerToggle<CR>', { silent = true })
