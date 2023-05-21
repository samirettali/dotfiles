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
-- autocmd("InsertEnter", {
--     callback = function()
--         vim.opt.relativenumber = false
--     end,
-- })
--
-- autocmd("InsertLeave", {
--     callback = function()
--         vim.opt.relativenumber = true
--     end,
-- })

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

-- autocmd("FileType", {
--     pattern = { "qf", "help", "man", "lspinfo" },
--     callback = function()
--         map("n", "q", ":close<CR>")
--     end,
-- })

-- TODO
-- autocmd("FileType", {
--     pattern = { "qf" },
--     callback = function()
--         vim.opt.buflisted = false
--     end,
-- })

-- autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
--     callback = function()
--         require("core.winbar").get_winbar()
--     end,
-- })

-- Fix moonfly colorscheme winbar highlights
local moonfly_highlights = vim.api.nvim_create_augroup("MoonflyHighlight", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "moonfly",
    callback = function()
        local palette = require("moonfly").palette
        vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey241, bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey241, bold = true })
        vim.api.nvim_set_hl(0, "FoldColumn", { bg = palette.black, fg = palette.grey241 })
    end,
    group = moonfly_highlights,
})

local nightfly_highlights = vim.api.nvim_create_augroup("NightflyHighlight", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "nightfly",
    callback = function()
        local palette = require("nightfly").palette
        vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey241, bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey241, bold = true })
    end,
    group = nightfly_highlights,
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

local fleet_highlights = vim.api.nvim_create_augroup("FleetHighlights", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "fleet",
    callback = function()
        local colors = require("fleet-theme.palette").palette

        vim.api.nvim_set_hl(0, "WinBar", { fg = colors.dark_gray, bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { fg = colors.dark_gray, bold = true })
        -- vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.dark_gray })
        -- vim.api.nvim_set_hl(0, "LineNr", { bg = colors.bg, fg = colors.line_fg })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = colors.bg, fg = colors.light })
        vim.api.nvim_set_hl(0, "TabLine", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "TabLineSel", { bg = colors.bg })
        vim.api.nvim_set_hl(0, "DiagnosticError", { bg = colors.bg, fg = colors.red_error })
        vim.api.nvim_set_hl(0, "DiagnosticWarn", { bg = colors.bg, fg = colors.orange_accent })
        vim.api.nvim_set_hl(0, "DiagnosticInfo", { bg = colors.bg, fg = colors.light })
        vim.api.nvim_set_hl(0, "DiagnosticHint", { bg = colors.bg, fg = colors.blue })
        -- vim.api.nvim_set_hl(0, "GitSignsUntracked", { bg = colors.red, fg = colors.bg })
        -- vim.api.nvim_set_hl(0, "StatusColumnSeparator", { bg = colors.bg, fg = colors.line_fg })
        --
        -- vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = colors.bg, fg = colors.green })
        -- vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = colors.bg, fg = colors.red_key_w })
        -- vim.api.nvim_set_hl(0, "GitSignsChange", { bg = colors.bg, fg = colors.diff_change })
        vim.api.nvim_set_hl(0, "FoldColumn", { bg = colors.bg, fg = colors.dark_gray })

        vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = colors.light_blue, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = colors.light_blue, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = colors.light_blue, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = colors.pink, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = colors.pink, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = colors.fg, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = colors.fg, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { fg = colors.fg, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = colors.orange, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = colors.green, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { fg = colors.yellow, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = colors.yellow, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemMenu', { fg = colors.fg, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemAbbr', { fg = colors.fg, bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated',
            { fg = colors.vscCursorDark, bg = colors.vscPopupBack, strikethrough = true })
        vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch',
            { fg = colors.blue, bg = 'NONE', bold = true })
        vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy',
            { fg = colors.blue, bg = 'NONE', bold = true })
    end,
    group = fleet_highlights,
})
