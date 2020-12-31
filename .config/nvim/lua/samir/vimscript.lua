vim.api.nvim_exec([[
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
    augroup END
]], false)

vim.api.nvim_exec([[
    autocmd VimResized * :wincmd =
]], false)

vim.api.nvim_exec([[
    let g:shebang_shells = { 'asd': 'dsadsdas' }
]], false)

vim.g.shebang_commands = {
    dsa = '/my/path/python'
}

-- vim.g.shebang_commands = {
--     dsa = '/my/path/python'
-- }
