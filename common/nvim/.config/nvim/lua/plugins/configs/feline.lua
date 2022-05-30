local present, feline = pcall(require, "feline")

if not present then
    return
end

local lsp = require("feline.providers.lsp")
local vi_mode_utils = require 'feline.providers.vi_mode'
local utils = require("core.utils")

-- local colors = {
--     bg = utils.get_hex("bg"),
--     fg = "#ffffff",
--     yellow = utils.get_hex("yellow"),
--     cyan = utils.get_hex("yellow"),
--     darkblue = "#528bff",
--     green = utils.get_hex("green"),
--     orange = utils.get_hex("yellow"),
--     violet = utils.get_hex("yellow"),
--     magenta = utils.get_hex("yellow"),
--     blue = utils.get_hex("yellow"),
--     red = utils.get_hex("yellow"),
-- }

-- local colors = {
--     alt = "#1c1c1c",
--     bg = "#303030",
--     black = "#323437",
--     blue = "#80a0ff",
--     cyan = "#79dac8",
--     err = "#EC5F67",
--     fg = "#c6c6c6",
--     green = "#8cc85f",
--     hint = "#5E81AC",
--     info = "#81A1C1",
--     magenta = "#d183e8",
--     red = "#ff5454",
--     warn = "#EBCB8B",
--     white = "#c6c6c6",
--     yellow = "#e3c78a"
-- }


local colors = require("core.colors").colors

local vi_mode_text = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    [''] = "V-BLOCK",
    V = "V-LINE",
    c = "COMMAND",
    no = "UNKNOWN",
    s = "UNKNOWN",
    S = "UNKNOWN",
    ic = "UNKNOWN",
    R = "REPLACE",
    Rv = "UNKNOWN",
    cv = "UNKWON",
    ce = "UNKNOWN",
    r = "REPLACE",
    rm = "UNKNOWN",
    t = "INSERT"
}

local vimode_colors = {
    n = "FlnViCyan",
    no = "FlnViCyan",
    i = "FlnStatus",
    v = "FlnViMagenta",
    V = "FlnViMagenta",
    [""] = "FlnViMagenta",
    R = "FlnViRed",
    Rv = "FlnViRed",
    r = "FlnViBlue",
    rm = "FlnViBlue",
    s = "FlnViMagenta",
    S = "FlnViMagenta",
    [""] = "FelnMagenta",
    c = "FlnViYellow",
    ["!"] = "FlnViBlue",
    t = "FlnViBlue",
}

local vimode_sep = {
    n = "FlnCyan",
    no = "FlnCyan",
    i = "FlnStatusBg",
    v = "FlnMagenta",
    V = "FlnMagenta",
    [""] = "FlnMagenta",
    R = "FlnRed",
    Rv = "FlnRed",
    r = "FlnBlue",
    rm = "FlnBlue",
    s = "FlnMagenta",
    S = "FlnMagenta",
    [""] = "FelnMagenta",
    c = "FlnYellow",
    ["!"] = "FlnBlue",
    t = "FlnBlue",
}

-- local chad_mode_hl = function()
--     return {
--         fg = vimode_colors[vim.fn.mode()][2],
--         bg = colors.bg,
--     }
-- end


local options = {
    lsp = lsp,
    lsp_severity = vim.diagnostic.severity,
}

local gps = require("nvim-gps")

gps.setup({
    icons = {
        ["class-name"] = " ", -- classes and class-like objects
        ["function-name"] = " ", -- functions
        ["method-name"] = " " -- methods (functions inside class-like objects)
    },
    languages = { -- you can disable any language individually here
        ["c"] = true,
        ["cpp"] = true,
        ["go"] = true,
        ["java"] = true,
        ["javascript"] = true,
        ["lua"] = true,
        ["python"] = true,
        ["rust"] = true,
    },
    separator = " > ",
})

options.icon_styles = {
    default = {
        left = "",
        right = " ",
        main_icon = "  ",
        vi_mode_icon = " ",
        position_icon = " ",
    },
    arrow = {
        left = "",
        right = "",
        main_icon = "  ",
        vi_mode_icon = " ",
        position_icon = " ",
    },

    block = {
        left = " ",
        right = " ",
        main_icon = "   ",
        vi_mode_icon = "  ",
        position_icon = "  ",
    },

    round = {
        left = "",
        right = "",
        main_icon = "  ",
        vi_mode_icon = " ",
        position_icon = " ",
    },

    slant = {
        left = " ",
        right = " ",
        main_icon = "  ",
        vi_mode_icon = " ",
        position_icon = " ",
    },
}

options.separator_style = options.icon_styles["slant"]
local function vi_mode_hl()
    return vimode_colors[vim.fn.mode()] or "FlnViBlack"
end

local function vi_sep_hl()
    return vimode_sep[vim.fn.mode()] or "FlnBlack"
end

local comps = {
    vimode = {
        provider = function()
            local current_text = ' ' .. vi_mode_text[vim.fn.mode()] .. ' '
            return current_text
        end,
        hl = function()
            local val = {
                name = vi_mode_utils.get_mode_highlight_name(),
                fg = colors.bg,
                bg = vi_mode_utils.get_mode_color(),
                style = 'bold'
            }
            return val
        end
        -- right_sep = ' '

    },
    file_name = {
        provider = require("core.utils").get_current_ufn,
        hl = {
            fg = colors.blue,
            style = "bold"
        },
        left_sep = " "
    },
    encoding = {
        provider = "file_encoding",
        left_sep = " ",
        hl = {
            fg = colors.violet,
            style = "bold"
        }
    },
    type = {
        provider = "file_type"
    },

    dir_name = {
        provider = function()
            local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            return "  " .. dir_name .. " "
        end,

        hl = {
            fg = colors.grey_fg2,
            bg = colors.lightbg2,
        },
        right_sep = {
            str = options.separator_style.right,
            hi = {
                fg = colors.lightbg2,
                bg = colors.bg,
            },
        },
    },

    diff = {
        add = {
            provider = "git_diff_added",
            hl = {
                fg = colors.green,
                bg = colors.bg,
            },
            icon = " ",
        },

        change = {
            provider = "git_diff_changed",
            hl = {
                fg = colors.orange,
                bg = colors.bg,
            },
            icon = "  ",
        },

        remove = {
            provider = "git_diff_removed",
            hl = {
                fg = colors.red,
                bg = colors.bg,
            },
            icon = "  ",
        },
    },
    git_branch = {
        provider = "git_branch",
        hl = {
            fg = colors.grey_fg2,
            bg = colors.bg,
        },
        icon = "  ",
    },

    diagnostic = {
        error = {
            provider = "diagnostic_errors",
            enabled = function()
                return options.lsp.diagnostics_exist(options.lsp_severity.ERROR)
            end,

            hl = { fg = colors.err },
            icon = "  ",
        },
        warning = {
            provider = "diagnostic_warnings",
            enabled = function()
                return options.lsp.diagnostics_exist(options.lsp_severity.WARN)
            end,
            hl = { fg = colors.warn },
            icon = "  ",
        },
        info = {
            provider = "diagnostic_info",
            enabled = function()
                return options.lsp.diagnostics_exist(options.lsp_severity.INFO)
            end,
            hl = { fg = colors.info },
            icon = "  ",
        },
        hint = {
            provider = "diagnostic_hints",
            enabled = function()
                return options.lsp.diagnostics_exist(options.lsp_severity.HINT)
            end,
            hl = { fg = colors.hint },
            icon = "  ",
        },

    },

    lsp_progress = {
        provider = function()
            local Lsp = vim.lsp.util.get_progress_messages()[1]

            if Lsp then
                local msg = Lsp.message or ""
                local percentage = Lsp.percentage or 0
                local title = Lsp.title or ""
                local spinners = {
                    "",
                    "",
                    "",
                }

                local success_icon = {
                    "",
                    "",
                    "",
                }

                local ms = vim.loop.hrtime() / 1000000
                local frame = math.floor(ms / 120) % #spinners

                if percentage >= 70 then
                    return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
                end

                return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
            end

            return ""
        end,
        hl = { fg = colors.green },

    },
    lsp_icon = {
        provider = function()
            if next(vim.lsp.buf_get_clients()) ~= nil then
                return "   LSP"
            else
                return ""
            end
        end,
        hl = { fg = colors.grey_fg2, bg = colors.bg },
    },

    empty_space = {
        provider = " " .. options.separator_style.left,
        hl = {
            fg = colors.one_bg2,
            bg = colors.bg,
        },
    },

    -- this matches the vi mode color
    empty_spaceColored = {
        provider = options.separator_style.left,
        hl = function()
            return {
                fg = vimode_colors[vim.fn.mode()],
                bg = colors.one_bg2,
            }
        end,
    },

    mode_icon = {
        provider = options.separator_style.vi_mode_icon,
        hl = function()
            return {
                fg = colors.bg,
                bg = vimode_colors[vim.fn.mode()],
            }
        end,
    },

    empty_space2 = {
        provider = function()
            return " " .. vimode_colors[vim.fn.mode()] .. " "
        end,
        -- hl = chad_mode_hl,
    },

    separator_right = {
        provider = options.separator_style.left,
        hl = {
            fg = colors.grey,
            bg = colors.one_bg,
        },
    },

    separator_right2 = {
        provider = options.separator_style.left,
        hl = {
            fg = colors.green,
            bg = colors.grey,
        },
    },

    position_icon = {
        provider = options.separator_style.position_icon,
        hl = {
            fg = colors.black,
            bg = colors.green,
        },
    },

    current_line = {
        provider = function()
            local current_line = vim.fn.line "."
            local total_line = vim.fn.line "$"

            if current_line == 1 then
                return " Top "
            elseif current_line == vim.fn.line "$" then
                return " Bot "
            end
            local result, _ = math.modf((current_line / total_line) * 100)
            return " " .. result .. "%% "
        end,

        hl = {
            fg = colors.green,
            bg = colors.one_bg,
        },
    },
}

local properties = {
    force_inactive = {
        filetypes = {
            "NvimTree",
            "dbui",
            "packer",
            "startify",
            "fugitive",
            "fugitiveblame",
            "vista_kind"
        },
        buftypes = { "terminal" },
        bufnames = {}
    }
}

local components = {
    active = {},
    inactive = {},
}

table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})

table.insert(components.active[1], comps.vimode)
table.insert(components.active[1], comps.file_name)
table.insert(components.active[1], comps.dir_name)
table.insert(components.active[1], comps.diff.add)
table.insert(components.active[1], comps.diff.change)
table.insert(components.active[1], comps.diff.remove)
table.insert(components.active[1], comps.diagnostic.error)
table.insert(components.active[1], comps.diagnostic.warning)
table.insert(components.active[1], comps.diagnostic.hint)
table.insert(components.active[1], comps.diagnostic.info)

table.insert(components.active[2], comps.lsp_icon)
table.insert(components.active[2], comps.git_branch)
table.insert(components.active[2], comps.empty_space)
table.insert(components.active[2], comps.empty_spaceColored)
table.insert(components.active[2], comps.mode_icon)
table.insert(components.active[2], comps.empty_space2)
table.insert(components.active[2], comps.separator_right)
table.insert(components.active[2], comps.separator_right2)
table.insert(components.active[2], comps.position_icon)
table.insert(components.active[2], comps.current_line)

feline.setup {
    default_bg = colors.bg,
    default_fg = colors.fg,
    components = components,
    properties = properties,
}
