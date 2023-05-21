local function config()
    if vim.g.colors_name == nil then
        -- Wait until colorscheme is loaded
        return
    end
    local lualine = require "lualine"

    local utils = require("core.utils")
    local icons = require("core.icons")

    local colors = {}

    if vim.g.colors_name == "moonfly" then
        local palette = require("moonfly").palette
        colors = {
            bg_alt  = palette.grey0,
            bg      = palette.bg,
            fg      = palette.fg,
            yellow  = palette.khaki,
            cyan    = palette.lime,
            green   = palette.emerald,
            orange  = palette.coral,
            magenta = palette.purple,
            blue    = palette.sky,
            red     = palette.crimson,
        }
    elseif vim.g.colors_name == "minimal" then
        local palette = require("minimal.colors")
        colors = {
            bg_alt  = palette.black,
            fg      = palette.fg,
            yellow  = palette.yellow,
            cyan    = palette.diff_text,
            green   = palette.green,
            orange  = palette.orange_wr,
            magenta = palette.pink,
            blue    = palette.blue_type,
            red     = palette.red_key_w,
        }
    elseif vim.g.colors_name == "fleet" then
        local palette = require("fleet-theme.palette").palette
        colors = {
            bg_alt  = palette.darker,
            fg      = palette.light,
            yellow  = palette.yellow,
            cyan    = palette.cyan,
            green   = palette.green,
            orange  = palette.orange,
            magenta = palette.purple,
            blue    = palette.blue,
            red     = palette.red,
            bg      = palette.background,
        }
    elseif vim.g.colors_name == "github_light" then
        local palette = require("github-theme.palette").load("github_light")
        colors = {
            bg_alt = palette.canvas.default,
            fg     = palette.black.base,
            red    = palette.red.base,
            green  = palette.green.base,
            yellow = palette.yellow.base,
            blue   = palette.blue.base,
            cyan   = palette.cyan.base,
            orange = palette.orange.base,
            violet = palette.pink.base,
        }
    elseif vim.g.colors_name == "vscode" then
        local palette = require("vscode.colors").get_colors()
        colors = {
            bg_alt = palette.vscBack,
            fg     = palette.vscFront,
            red    = palette.vscRed,
            green  = palette.vscBlueGreen,
            yellow = palette.vscDarkYellow,
            blue   = palette.vscBlue,
            cyan   = palette.vscMediumBlue,
            orange = palette.vscOrange,
            violet = palette.vscPink,
        }
    end

    local theme = {
        normal = { c = { bg = colors.bg } },
        inactive = { c = { bg = colors.bg } },
    }

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand("%:p:h")
            local gitdir = vim.fn.finddir(".git", filepath .. ";")
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
    }

    local options = {
        options = {
            theme = theme,
            icons_enabled = true,
            globalstatus = true,
            always_divide_middle = true,
            component_separators = "",
            section_separators = "",
            disabled_filetypes = {
                statusline = {},
                winbar = {}
            },
            ignore_focus = {},
            refresh = {
                statusline = 1000,
            },
        },
        sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },
        tabline = {},
    }


    local function ins_left(component)
        -- local color = component.color
        -- if color == nil then
        --     color = { bg = colors.bg_alt }
        -- elseif type(color) == "table" then
        --     color.bg = colors.bg_alt
        -- end
        -- component.color = color
        table.insert(options.sections.lualine_c, component)
    end

    local function ins_right(component)
        -- local color = component.color
        -- if color == nil then
        --     color = { bg = colors.bg_alt }
        -- elseif type(color) == "table" then
        --     color.bg = colors.bg_alt
        -- end
        -- component.color = color
        table.insert(options.sections.lualine_x, component)
    end

    ins_left {
        "mode",
        -- icon = icons.ui.block,
        color = function()
            local mode_color = {
                n = colors.blue,
                i = colors.cyan,
                v = colors.magenta,
                [""] = colors.magenta,
                V = colors.magenta,
                c = colors.magenta,
                no = colors.red,
                s = colors.orange,
                S = colors.orange,
                [""] = colors.orange,
                ic = colors.yellow,
                R = colors.magenta,
                Rv = colors.magenta,
                cv = colors.red,
                ce = colors.red,
                r = colors.cyan,
                rm = colors.cyan,
                ["r?"] = colors.cyan,
                ["!"] = colors.red,
                t = colors.red,
            }
            return { bg = mode_color[vim.fn.mode()], fg = colors.bg }
        end,
        padding = { right = 1, left = 1 },
    }

    ins_left {
        "branch",
        icon = icons.git.branch,
        color = { fg = colors.blue, bg = colors.bg_alt },
    }

    ins_left {
        function()
            return ""
        end,
        color = { fg = colors.bg_alt, bg = colors.bg },
        padding = { right = 0 },
    }

    -- ins_right {
    --     function()
    --         return ""
    --     end,
    --     color = { fg = colors.bg, bg = colors.bg }
    -- }

    -- ins_left {
    --     "diagnostics",
    --     sources = { "nvim_diagnostic" },
    --     sections = { "error", "warn", "info", "hint" },
    --     symbols = {
    --         error = "E:",
    --         warn = icons.diagnostics.warn,
    --         info = icons.diagnostics.info,
    --         hint = icons.diagnostics.hint,
    --     },
    -- }


    -- Show file encoding if not UTF-8
    ins_right {
        function()
            local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
            return ret
        end,
        fmt = string.upper,
        color = { fg = colors.blue }
    }

    -- Show file format if not UNIX
    ins_right {
        function()
            local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
            return ret
        end,
        fmt = string.upper,
        color = { fg = colors.blue }
    }

    lualine.setup(options)
end

local group = vim.api.nvim_create_augroup("PluginRefresh", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = config,
    group = group,
})


return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "projekt0n/github-nvim-theme",
            "Yazeed1s/minimal.nvim",
            "bluz71/vim-moonfly-colors",
            "Yazeed1s/oh-lucy.nvim",
            "AlexvZyl/nordic.nvim",
            "Mofiqul/vscode.nvim",
        },
        config = config,
    }
}
