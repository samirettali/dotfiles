vim.api.nvim_exec([[
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
    augroup END
]], false)

vim.api.nvim_exec([[
    autocmd VimResized * :wincmd =
]], false)

--[[
vim.api.nvim_exec([[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
\]\], false)--]]

-- vim.api.nvim_exec([[
--   inoremap <silent><expr> <C-n>     compe#complete()
--   inoremap <silent><expr> <CR>      compe#confirm('<CR>')
--   inoremap <silent><expr> <C-e>     compe#close('<C-e>')
--   inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
--   inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
-- 
--   inoremap <silent><expr> <Tab>     pumvisible() ? "\<C-n>" : "\<Tab>"
--   inoremap <silent><expr> <S-Tab>   pumvisible() ? "\<C-p>" : "\<S-Tab>"
-- ]], false)
-- 
vim.api.nvim_exec([[
  augr class
  au!
  au bufreadpost,filereadpost *.class %!/usr/bin/jad -noctor -ff -i -p %
  au bufreadpost,filereadpost *.class set readonly
  au bufreadpost,filereadpost *.class set ft=java
  au bufreadpost,filereadpost *.class normal gg=G
  au bufreadpost,filereadpost *.class set nomodified
  augr END
]], false)
