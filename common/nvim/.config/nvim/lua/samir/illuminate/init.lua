vim.g.Illuminate_ftblacklist = { 'NvimTree' }
vim.g.Illuminate_delay = 250

vim.api.nvim_exec([[
  augroup illuminate_augroup
      autocmd!
      autocmd VimEnter * hi link illuminatedWord Visual
  augroup END
]], false)
