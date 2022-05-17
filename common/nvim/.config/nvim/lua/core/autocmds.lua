#!/usr/bin/env lua
local autocmd = vim.api.nvim_create_autocmd

-- Disable statusline in dashboard
autocmd("FileType", {
   pattern = "alpha",
   callback = function()
      vim.opt.laststatus = 0
   end,
})

autocmd("BufUnload", {
   buffer = 0,
   callback = function()
      vim.opt.laststatus = 3
   end,
})

autocmd("VimResized", {
   buffer = 0,
   callback = function()
      vim.opt.laststatus = 3
   end,
})

-- Set spell checking for text and markdown files
autocmd("BufEnter", {
   pattern = {"*.txt", "*.md"},
   callback = function()
       print('spell on')
       vim.api.nvim_win_set_option(0, "spell", true)
   end,
})

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- pattern = "help,lspinfo,qf,startuptime",
-- callback = function()
--     vim.api.nvim_set_keymap(
--         "n",
--         "q",
--         "<cmd>close<CR>",
--         { noremap = true, silent = true }
--     )
-- end,


-- open nvim with a dir while still lazy loading nvimtree
-- autocmd("BufEnter", {
--    callback = function()
--       if vim.api.nvim_buf_get_option(0, "buftype") ~= "terminal" then
--          vim.cmd "lcd %:p:h"
--       end
--    end,
-- })

-- Use relative & absolute line numbers in 'n' & 'i' modes respectively
-- autocmd("InsertEnter", {
--    callback = function()
--       vim.opt.relativenumber = false
--    end,
-- })
-- autocmd("InsertLeave", {
--    callback = function()
--       vim.opt.relativenumber = true
--    end,
-- })

-- Open a file from its last left off position
-- autocmd("BufReadPost", {
--    callback = function()
--       if not vim.fn.expand("%:p"):match ".git" and vim.fn.line "'\"" > 1 and vim.fn.line "'\"" <= vim.fn.line "$" then
--          vim.cmd "normal! g'\""
--          vim.cmd "normal zz"
--       end
--    end,
-- })

-- File extension specific tabbing
-- autocmd("Filetype", {
--    pattern = "python",
--    callback = function()
--       vim.opt_local.expandtab = true
--       vim.opt_local.tabstop = 4
--       vim.opt_local.shiftwidth = 4
--       vim.opt_local.softtabstop = 4
--    end,
-- })

-- Highlight yanked text
-- autocmd("TextYankPost", {
--    callback = function()
--       vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
--    end,
-- })

-- Enable spellchecking in markdown, text and gitcommit files
-- autocmd("FileType", {
--    pattern = { "gitcommit", "markdown", "text" },
--    callback = function()
--       vim.opt_local.spell = true
--    end,
-- })


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

