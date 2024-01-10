vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    desc = "Automatically resize windows when terminal is resized",
    command = "wincmd =",
})

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Highlight yanked text",
    pattern = '*',
    group = highlight_group,
    callback = vim.highlight.on_yank,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Close help, man, quickfix, lspinfo with q",
    pattern = { "qf", "help", "man", "lspinfo" },
    callback = function()
        vim.keymap.set("n", "q", ":close<CR>")
    end,
})

local user = vim.api.nvim_create_augroup("user", {})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    desc = "Return cursor to where it was last time closing the file",
    group = user,
    pattern = "*",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

-- Create parent folder if it doesnt exist when saving a file
-- TODO: convert to lua
vim.cmd [[ au BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif ]]

local group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
    vim.api.nvim_create_autocmd(event, {
        desc = "Keep cursor line only on focused window",
        group = group,
        pattern = pattern,
        callback = function()
            vim.opt_local.cursorline = value
        end,
    })
end
set_cursorline("WinEnter", true)
set_cursorline("InsertLeave", true)
set_cursorline("InsertEnter", false)
set_cursorline("WinLeave", false)
set_cursorline("FileType", false, "TelescopePrompt")
