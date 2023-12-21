vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    command = "wincmd =",
})

-- Highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "qf", "help", "man", "lspinfo" },
    callback = function()
        vim.keymap.set("n", "q", ":close<CR>")
    end,
})

-- TODO
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "qf" },
--     callback = function()
--         vim.opt.buflisted = false
--     end,
-- })

local user = vim.api.nvim_create_augroup("user", {})
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    group = user,
    desc = 'return cursor to where it was last time closing the file',
    pattern = '*',
    command = 'silent! normal! g`"zv',
})
