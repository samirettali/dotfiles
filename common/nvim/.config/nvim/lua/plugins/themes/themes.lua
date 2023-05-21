return {
    { 'rose-pine/neovim', name = 'rose-pine' },
    {
        "felipeagc/fleet-theme-nvim",
        config = function()
            -- vim.cmd [[ colorscheme fleet ]]
        end,
    },
    {
        "bluz71/vim-moonfly-colors",
        config = function()
            vim.g.moonflyWinSeparator = 2
            vim.g.moonflyCursorColor = true
            vim.g.moonflyItalics = false
            vim.g.moonflyUnderlineMatchParen = true
            vim.cmd [[ colorscheme moonfly ]]
        end
    },
    {
        "EdenEast/nightfox.nvim"

    },
    { "sainnhe/sonokai" },
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
        "AlexvZyl/nordic.nvim",
        config = function()
            local nordic = require "nordic"
            local colors = require 'nordic.colors'

            local config = {
                bold_keywords = true,
                italic_comments = true,
                transparent_bg = false,
                reduced_blue = true,
                override = {
                    WinBar = {
                        bg = colors.bg,
                        fg = colors.fg,
                    },
                    WinBarNC = {
                        bg = colors.bg,
                        fg = colors.fg,
                    },
                },
                cursorline = {
                    bold = false,
                    theme = "light",
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
}
