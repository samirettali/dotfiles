local function config()
    if vim.g.colors_name == nil then
        -- Wait until colorscheme is loaded
        return
    end
    local lualine = require "lualine"

    local icons = require("core.icons")

    local colors = {}

    if vim.g.colors_name == "moonfly" then
        local palette = require("moonfly").palette
        colors = {
            bg_alt  = palette.grey234,
            grey    = palette.grey0,
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
        normal = { c = { bg = colors.bg_alt } },
        inactive = { c = { bg = colors.bg_alt } },
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
        color = { fg = colors.blue, bg = colors.grey },
    }

    -- ins_left {
    --     function()
    --         return ""
    --     end,
    --     color = { fg = colors.bg_alt, bg = colors.bg },
    --     padding = { right = 0 },
    -- }

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

local function config2()
    -- Using Lualine as the statusline.

-- Show git status.
local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed } end
end

-- Get the current buffer's filetype.
local function get_current_filetype() return vim.api.nvim_buf_get_option(0, 'filetype') end

-- Get the current buffer's type.
local function get_current_buftype() return vim.api.nvim_buf_get_option(0, 'buftype') end

-- Get the buffer's filename.
local function get_current_filename()
    local bufname = vim.api.nvim_buf_get_name(0)
    return bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or ''
end

local function copilot_normal()
    local status = require('copilot.api').status.data.status
    if
        string.find(status, 'Online')
        or string.find(status, 'Enabled')
        or string.find(status, 'Normal')
        or string.find(status, 'InProgress')
    then
        return '  '
    end
    return ''
end

local function copilot_warn()
    local status = require('copilot.api').status.data.status
    if string.find(status, 'Warning') then return '  ' end
    return ''
end

local function copilot_error()
    local status = require('copilot.api').status.data.status
    if string.find(status, 'Error') then return '  ' end
    return ''
end

-- Gets the current buffer's filename with the filetype icon supplied
-- by devicons.
local M = require('lualine.components.filetype'):extend()
Icon_hl_cache = {}
local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
    highlight = 'lualine.highlight',
    utils = 'lualine.utils.utils',
}

function M:get_current_filetype_icon()
    -- Get setup.
    local icon, icon_highlight_group
    local _, devicons = pcall(require, 'nvim-web-devicons')
    local f_name, f_extension = vim.fn.expand '%:t', vim.fn.expand '%:e'
    f_extension = f_extension ~= '' and f_extension or vim.bo.filetype
    icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)

    -- Fallback settings.
    if icon == nil and icon_highlight_group == nil then
        icon = ''
        icon_highlight_group = 'DevIconDefault'
    end

    -- Set colors.
    local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
    if highlight_color then
        -- local default_highlight = self:get_default_hl()
        local icon_highlight = Icon_hl_cache[highlight_color]
        if not icon_highlight or not modules.highlight.highlight_exists(icon_highlight.name .. '_normal') then
            icon_highlight = self:create_hl({ fg = highlight_color }, icon_highlight_group)
            Icon_hl_cache[highlight_color] = icon_highlight
        end
        -- icon = self:format_hl(icon_highlight) .. icon .. default_highlight
    end

    -- Return the formatted string.
    return icon
end

function M:get_current_filename_with_icon()
    local suffix = ''

    -- Get icon and filename.
    local icon = M.get_current_filetype_icon(self)
    local f_name = get_current_filename()

    -- Add readonly icon.
    local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
    local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
    local nofile = get_current_buftype() == 'nofile'
    if readonly or nofile or not modifiable then suffix = ' ' end

    -- Return the formatted string.
    return icon .. ' ' .. f_name .. suffix
end

local function parent_folder()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local parent = vim.fn.fnamemodify(current_file, ':h:t')
    if parent == '.' then return '' end
    return parent .. '/'
end

local function get_native_lsp()
    local buf_ft = get_current_filetype()
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then return '' end
    for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and client.name ~= 'copilot' then return client.name end
    end
    return ''
end

-- Display the difference in commits between local and head.
local Job = require 'plenary.job'
local function get_git_compare()
    -- Get the path of the current directory.
    local curr_dir = vim.api.nvim_buf_get_name(0):match('(.*' .. '/' .. ')')

    -- Run job to get git.
    local result = Job:new({
        command = 'git',
        cwd = curr_dir,
        args = { 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' },
    })
        :sync(100)[1]

    -- Process the result.
    if type(result) ~= 'string' then return '' end
    local ok, ahead, behind = pcall(string.match, result, '(%d+)%s*(%d+)')
    if not ok then return '' end

    -- No file, so no git.
    if get_current_buftype() == 'nofile' then return '' end
    local string = ''
    if behind ~= '0' then string = string .. '󱦳' .. behind end
    if ahead ~= '0' then string = string .. '󱦲' .. ahead end
    return string
end

-- Required to properly set the colors.
local c = require 'nordic.colors'

local function get_short_cwd() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end
local tree = {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { '' },
                separator = { right = ' ', left = '' },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                get_short_cwd,
                padding = 0,
                icon = { '   ', color = { fg = c.gray4 } },
                color = { fg = c.gray3 },
            },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            {
                'location',
                icon = { '', align = 'left', color = { fg = c.black } },
            },
            {
                'progress',
                icon = { '', align = 'left', color = { fg = c.black } },
                separator = { right = '', left = '' },
            },
        },
    },
    filetypes = { 'NvimTree' },
}

local function telescope_text() return 'Telescope' end

local telescope = {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { '' },
                separator = { right = ' ', left = '' },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                telescope_text,
                color = { fg = c.gray3 },
                icon = { '  ', color = { fg = c.gray4 } },
            },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            {
                'location',
                icon = { '', align = 'left', color = { fg = c.black } },
            },
            {
                'progress',
                icon = { '', align = 'left', color = { fg = c.black } },
                separator = { right = '', left = '' },
            },
        },
    },
    filetypes = { 'TelescopePrompt' },
}

require('lualine').setup {
    sections = {
        lualine_a = {
            {
                'mode',
                icon = { '' },
                separator = { right = ' ', left = '' },
            },
        },
        lualine_b = {},
        lualine_c = {
            {
                parent_folder,
                color = { fg = c.gray3 },
                icon = { '   ', color = { fg = c.gray4 } },
                separator = '',
                padding = 0,
            },
            {
                get_current_filename,
                color = { fg = c.gray3 },
                separator = ' ',
                padding = 0,
            },
            {
                'branch',
                color = { fg = c.gray3 },
                icon = { '   ', color = { fg = c.gray4 } },
                separator = ' ',
                padding = 0,
            },
            {
                get_git_compare,
                separator = ' ',
                padding = 0,
                color = { fg = c.gray3 },
            },
            {
                'diff',
                padding = 0,
                color = { fg = c.gray3 },
                icon = { ' ', color = { fg = c.gray3 } },
                source = diff_source,
                symbols = { added = ' ', modified = ' ', removed = ' ' },
                diff_color = {
                    added = { fg = c.gray4 },
                    modified = { fg = c.gray4 },
                    removed = { fg = c.gray4 },
                },
            },
        },
        lualine_x = {
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = '󱤅 ', other = '󰠠 ' },
                diagnostics_color = {
                    error = { fg = c.error },
                    warn = { fg = c.warn },
                    info = { fg = c.info },
                    hint = { fg = c.hint },
                },
                colored = true,
                padding = 1,
            },
            {
                get_native_lsp,
                padding = 2,
                separator = ' ',
                color = { fg = c.gray3 },
                icon = { ' ', color = { fg = c.gray4 } },
            },
            { copilot_normal, color = { fg = c.gray4 }, padding = 0 },
            { copilot_warn, color = { fg = c.yellow.base }, padding = 0 },
            { copilot_error, color = { fg = c.red.base }, padding = 0 },
        },
        lualine_y = {},
        lualine_z = {
            {
                'location',
                icon = { '', align = 'left', color = { fg = c.black } },
            },
            {
                'progress',
                icon = { '', align = 'left', color = { fg = c.black } },
                separator = { right = '', left = '' },
            },
        },
    },
    options = {
        disabled_filetypes = { 'dashboard' },
        globalstatus = true,
        section_separators = { left = ' ', right = ' ' },
        component_separators = { left = '', right = '' },
        theme = 'nordic',
    },
    extensions = {
        telescope,
        ['nvim-tree'] = tree,
    },
}

-- Ensure correct backgrond for lualine.
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    callback = function(_) require('lualine').setup() end,
    pattern = { '*.*' },
    once = true,
})
end

local group = vim.api.nvim_create_augroup("PluginRefresh", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = config2,
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
        config = config2,
    }
}
