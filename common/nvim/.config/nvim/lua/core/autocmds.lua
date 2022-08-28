#!/usr/bin/env lua
local autocmd = vim.api.nvim_create_autocmd
local utils = require("core.utils")
local map = utils.map

autocmd("VimResized", {
    pattern = "*",
    command = "wincmd =",
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
    pattern = { "text", "markdown", "gitcommit" },
    callback = function()
        vim.api.nvim_win_set_option(0, "spell", true)
    end,
})

-- TODO
-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins.lua source <afile> | PackerCompile
--   augroup end
-- ]])

-- open nvim with a dir while still lazy loading nvimtree
-- autocmd("BufEnter", {
--    callback = function()
--       if vim.api.nvim_buf_get_option(0, "buftype") ~= "terminal" then
--          vim.cmd "lcd %:p:h"
--       end
--    end,
-- })

-- Use relative & absolute line numbers in 'n' & 'i' modes respectively
autocmd("InsertEnter", {
    callback = function()
        vim.opt.relativenumber = false
    end,
})
autocmd("InsertLeave", {
    callback = function()
        vim.opt.relativenumber = true
    end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 400 }
    end,
})

-- Enable spellchecking in markdown, text and gitcommit files
autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
        vim.opt_local.spell = true
    end,
})

autocmd("FileType", {
    pattern = { "qf", "help", "man", "lspinfo" },
    callback = function()
        map("n", "q", ":close<CR>")
    end,
})

-- TODO
-- autocmd("FileType", {
--     pattern = { "qf" },
--     callback = function()
--         vim.opt.buflisted = false
--     end,
-- })

autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
    callback = function()
        require("core.winbar").get_winbar()
    end,
})

autocmd("BufWritePost", {
    pattern = "*.lua",
    callback = function()
        dofile(vim.fn.expand('%'))
    end,
})
