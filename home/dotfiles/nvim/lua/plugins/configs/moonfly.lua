return {
    "bluz71/vim-moonfly-colors",
    priority = 1000,
    config = function()
        vim.g.moonflyWinSeparator = 2
        vim.g.moonflyCursorColor = true
        vim.g.moonflyItalics = false
        vim.g.moonflyUnderlineMatchParen = true

        local moonfly_highlights = vim.api.nvim_create_augroup("MoonflyHighlight", {})
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "moonfly",
            callback = function()
                local palette = require("moonfly").palette

                vim.api.nvim_set_hl(0, "WinBar", { bg = palette.black, fg = palette.grey247 })
                vim.api.nvim_set_hl(0, "WinBarNC", { bg = palette.black, fg = palette.grey247 })
                vim.api.nvim_set_hl(0, "FoldColumn", { bg = palette.black, fg = palette.grey241 })
                vim.api.nvim_set_hl(0, "CursorLineNr", { bg = palette.black, fg = palette.blue })
                vim.api.nvim_set_hl(0, "BiscuitColor", { bg = palette.grey234, fg = palette.grey241 })
                vim.api.nvim_set_hl(0, "TreesitterContext", { bg = palette.grey234 })


                local default_status_bg = palette.grey234;
                local default_status_fg = palette.white;
                local alt_status_bg = "#191919";

                vim.api.nvim_set_hl(0, "Statusline", {
                    bg = default_status_bg,
                    fg = default_status_fg,
                })

                vim.api.nvim_set_hl(0, "StatuslineBGBlue", {
                    bg = palette.blue,
                    fg = default_status_bg
                })

                vim.api.nvim_set_hl(0, "StatuslineFilename", {
                    bg = alt_status_bg,
                    fg = default_status_fg,
                })

                vim.api.nvim_set_hl(0, "StatuslineBranch", {
                    bg = alt_status_bg,
                    fg = default_status_fg,
                })

                vim.api.nvim_set_hl(0, "DiagnosticSignError", {
                    bg = default_status_bg,
                    fg = palette.red
                })
                vim.api.nvim_set_hl(0, "DiagnosticSignWarn", {
                    bg = default_status_bg,
                    fg = palette.yellow
                })
                vim.api.nvim_set_hl(0, "DiagnosticSignHint", {
                    bg = default_status_bg,
                    fg = palette.purple,
                })
                vim.api.nvim_set_hl(0, "DiagnosticSignInfo", {
                    bg = default_status_bg,
                    fg = palette.sky
                })
            end,
            group = moonfly_highlights,
        })

        vim.cmd.colorscheme("moonfly")
    end
}