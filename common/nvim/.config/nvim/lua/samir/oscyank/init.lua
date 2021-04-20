map('v', '<C-c>', ':OSCYank<CR>')

-- Fix for kitty different escape code
vim.g.oscyank_term = 'kitty'
