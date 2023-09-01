return {
    { 'p00f/alabaster.nvim' },
    { 'rose-pine/neovim',   name = 'rose-pine' },
    {
        "felipeagc/fleet-theme-nvim",
        config = function()
            -- vim.cmd [[ colorscheme fleet ]]
        end,
    },
    {
        "bluz71/vim-moonfly-colors",
        priority = 1000,
        config = function()
            vim.g.moonflyWinSeparator = 2
            vim.g.moonflyCursorColor = true
            vim.g.moonflyItalics = false
            vim.g.moonflyUnderlineMatchParen = true
            vim.cmd [[ colorscheme moonfly ]]
        end
    },
    { "Alexis12119/nightly.nvim" },
    {
        "EdenEast/nightfox.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd [[ colorscheme nightfox ]]
        end
    },
    { "sainnhe/sonokai" },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        -- config = function() vim.cmd [[ colorscheme catppuccin ]] end
    },

    {
        "projekt0n/github-nvim-theme",
        config = function()
            -- vim.cmd [[ colorscheme github_light ]]
        end
    },
    {
        "bluz71/vim-nightfly-colors",
        config = function()
            -- vim.cmd [[ colorscheme nightfly ]]
        end,
    },
    {
        "Yazeed1s/minimal.nvim",
        config = function()
            -- vim.cmd [[ colorscheme minimal ]]
        end,
    },
    {
        "Yazeed1s/oh-lucy.nvim"
    },
    {
        "Mofiqul/vscode.nvim"
    },
    {
        'rebelot/kanagawa.nvim',
    },
    {
        "AlexvZyl/nordic.nvim",
        priority = 1000,
        config = function()
            local nordic = require "nordic"
            local colors = require 'nordic.colors'
            -- Overrides.
            local p = require 'nordic.colors'
            local override = {
                CursorLine = { bg = p.bg },
                CursorLineNr = { bold = false },
                PopupNormal = { bg = p.bg_dark },
                PopupBorder = { bg = p.bg_dark, fg = p.grey1 },
                Pmenu = { link = 'PopupNormal' },
                PmenuSel = { bg = p.grey0 },
                PmenuBorder = { link = 'PopupBorder' },
                PmenuDocBorder = { bg = p.bg_dark, fg = p.grey1 },
                NormalFloat = { bg = p.bg_dark },
                FloatBorder = { bg = p.bg_dark },
                NoiceCmdlineIcon = { bg = p.bg_dark },
                NoiceCmdlinePopupBorder = { fg = p.cyan.base },
                SagaBorder = { bg = p.bg_dark, fg = p.grey1 },
                SagaNormal = { bg = p.bg_dark },
                NoiceLspProgressTitle = { fg = p.yellow.base, bg = p.bg, bold = true },
                NoiceLspProgressClient = { fg = p.gray4, bg = p.bg },
                NoiceLspProgressSpinner = { fg = p.cyan.bright, bg = p.bg },
                NoiceFormatProgressDone = { bg = p.green.bright, fg = p.black },
                NoiceFormatProgressTodo = { bg = p.gray5, fg = p.black },
                CmpItemKindTabNine = { fg = p.red.base },
                CmpItemKindCopilot = { fg = p.red.base },
                TelescopePreviewLine = { bg = p.gray0 },
                CopilotSuggestion = { fg = p.gray2 },
                NvimTreeWinSeparator = { fg = p.gray1, bg = p.bg },
                WinSeparator = { fg = p.gray1 },
                WhichKeyBorder = { fg = p.gray1, bg = p.bg_dark },
                WinBar = {
                    bg = colors.bg,
                    fg = colors.fg,
                },
                WinBarNC = {
                    bg = colors.bg,
                    fg = colors.fg,
                },
                FoldColumn = {
                    bg = colors.bg,
                    fg = colors.fg_sidebar,
                }
            }

            local config = {
                bold_keywords = true,
                italic_comments = false,
                transparent_bg = false,
                reduced_blue = false,
                override = override,
                nordic = {
                    bright_border = false,
                },
                cursorline = {
                    bold = false,
                    theme = "dark",
                },
                noice = {
                    style = "flat" -- classic | flat
                },
                telescope = {
                    style = "flat", -- classic | flat
                },
            }

            nordic.setup(config)
            -- nordic.load()
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
        end,
    },
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            -- Lua
            require('onedark').setup {
                style = 'darker'
            }
            -- require('onedark').load()
        end
    }
}
