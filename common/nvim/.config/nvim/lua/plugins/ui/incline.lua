local function get_diagnostic_label(props)
    local severities = { "ERROR", "WARN", "INFO", "HINT" }

    local label = {}
    for _, severity in pairs(severities) do
        local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity] })
        if n > 0 then
            table.insert(label, { n .. " ", group = "DiagnosticSign" .. severity })
        end
    end
    return label
end

local function config()
    require("incline").setup {
        debounce_threshold = {
            falling = 50,
            rising = 10
        },
        hide = {
            cursorline = true,
            focused_win = false,
            only_win = false
        },
        highlight = {
            groups = {
                InclineNormal = {
                    default = true,
                    group = "NormalFloat"
                },
                InclineNormalNC = {
                    default = true,
                    group = "NormalFloat"
                }
            }
        },
        ignore = {
            buftypes = "special",
            filetypes = {},
            floating_wins = true,
            unlisted_buffers = true,
            wintypes = "special"
        },
        render = function(props)
            -- TODO if not focused, also diagnostic colors should be dimmed
            local bufname = vim.api.nvim_buf_get_name(props.buf)
            -- TODO handle different relative path
            local filename = vim.fn.fnamemodify(bufname, ":.")
            local diagnostics = get_diagnostic_label(props)
            local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and "bold,italic" or "None"

            local buffer = {
                { filename, gui = modified },
            }

            if #diagnostics > 0 then
                table.insert(diagnostics, { "| ", guifg = "grey" })
            end
            for _, buffer_ in ipairs(buffer) do
                table.insert(diagnostics, buffer_)
            end

            local palette = require("fleet-theme.palette").palette
            local colors = {
                bg = palette.darker,
                black = palette.background,
                fg = palette.light,
                fg_dimmed = palette.dark,
            }

            local origin_diag = #diagnostics;

            table.insert(diagnostics, 1, { "", guifg = colors.bg, guibg = colors.black })
            table.insert(diagnostics, 2, " ")
            table.insert(diagnostics, 3, { guifg = colors.fg, guibg = colors.black })
            if origin_diag > 1 then
                table.insert({ " " }, { guifg = colors.fg, guibg = colors.black })
            end
            table.insert(diagnostics, { "", guifg = colors.bg, guibg = colors.black })

            if props.focused == true then
                return {
                    {
                        diagnostics,
                        guibg = colors.bg,
                        guifg = colors.fg
                    }
                }
            else
                return {
                    {
                        diagnostics,
                        guibg = colors.bg,
                        guifg = colors.fg_dimmed,
                    }
                }
            end
        end,
        window = {
            margin = {
                horizontal = 1,
                vertical = 1,
            },
            options = {
                signcolumn = "no",
                wrap = false
            },
            padding = 0,
            -- padding_char = " ",
            placement = {
                horizontal = "right",
                vertical = "top"
            },
            width = "fit",
            winhighlight = {
                active = {
                    EndOfBuffer = "None",
                    Normal = "InclineNormal",
                    Search = "None"
                },
                inactive = {
                    EndOfBuffer = "None",
                    Normal = "InclineNormalNC",
                    Search = "None"
                }
            },
            zindex = 50
        }
    }
end

return {
    {
        "b0o/incline.nvim",
        config = config,
    }
}
