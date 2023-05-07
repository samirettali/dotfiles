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

-- Fix moonfly colorscheme winbar highlights
local moonfly_highlights = vim.api.nvim_create_augroup("MoonflyHighlight", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "moonfly",
    callback = function()
        vim.api.nvim_set_hl(0, "WinBar", { bg = "#080808", bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = "#080808", bold = true })
    end,
    group = moonfly_highlights,
})

local minimal_highlights = vim.api.nvim_create_augroup("MinimalHighlights", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "minimal",
    callback = function()
        local colors = require("minimal.colors")

        vim.api.nvim_set_hl(0, "WinBar", { fg = colors.comment, bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { fg = colors.comment, bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.comment })
        vim.api.nvim_set_hl(0, "LineNr", { bg = colors.bg, fg = colors.line_fg })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = colors.bg, fg = colors.fg })
        vim.api.nvim_set_hl(0, "GitSignsUntracked", { bg = colors.red, fg = colors.bg })
        vim.api.nvim_set_hl(0, "StatusColumnSeparator", { bg = colors.bg, fg = colors.line_fg })

        vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = colors.bg, fg = colors.green })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = colors.bg, fg = colors.red_key_w })
        vim.api.nvim_set_hl(0, "GitSignsChange", { bg = colors.bg, fg = colors.diff_change })
    end,
    group = minimal_highlights,
})
