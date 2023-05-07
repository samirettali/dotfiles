local present, lualine = pcall(require, "lualine")
if not present then
    return false
end

local colors = require("minimal.colors")
local utils = require("core.utils")

colors = {
    bg       = colors.black,
    fg       = colors.fg,
    yellow   = colors.yellow,
    cyan     = colors.diff_text,
    darkblue = colors.black1,
    green    = colors.green,
    orange   = colors.orange_wr,
    violet   = colors.orange,
    magenta  = colors.pink,
    blue     = colors.blue_type,
    red      = colors.red_key_w,
}

local theme = {
    -- replace = {
    --     a = { fg = colors.color0, bg = theme.bg, gui = 'bold' },
    --     b = { fg = colors.color2, bg = theme.bg },
    -- },
    -- inactive = {
    --     a = { fg = colors.color6, bg = theme.bg, gui = 'bold' },
    --     b = { fg = colors.color6, bg = theme.bg },
    --     c = { fg = colors.color6, bg = theme.bg },
    -- },
    -- normal = {
    --     a = { fg = colors.color0, bg = theme.bg, gui = 'bold' },
    --     b = { fg = colors.color2, bg = theme.bg },
    --     c = { fg = colors.color2, bg = theme.bg },
    -- },
    -- visual = {
    --     a = { fg = colors.color0, bg = theme.bg, gui = 'bold' },
    --     b = { fg = colors.color2, bg = theme.bg },
    -- },
    -- insert = {
    --     a = { fg = colors.color0, bg = theme.bg, gui = 'bold' },
    --     b = { fg = colors.color2, bg = theme.bg },
    -- },
    normal = { c = { fg = colors.fg, bg = colors.bg } },
    inactive = { c = { fg = colors.fg, bg = colors.bg } },
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
            tabline = 1000,
            winbar = 1000
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
}


-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(options.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
    table.insert(options.sections.lualine_x, component)
end

-- ins_left {
--     function()
--         return "▊"
--     end,
--     color = { fg = colors.blue },      -- Sets highlighting of component
--     padding = { left = 0, right = 1 }, -- We don't need space before this
-- }

ins_left {
    -- mode component
    "mode",
    icon = "▊",
    color = function()
        local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
    end,
    padding = { right = 1 },
}

ins_left {
    "branch",
    color = { fg = colors.green, gui = "bold" },
}

ins_left {
    "filename",
    icon = "",
    cond = function()
        return conditions.buffer_not_empty() and not utils.is_plugin_filetype()
    end,
    color = { fg = colors.magenta, gui = "bold" },
    file_status = true,     -- Displays file status (readonly status, modified status)
    newfile_status = false, -- Display new file status (new file means no write after created)
    path = 1,               -- 0: Just the filename
    -- 1: Relative path
    -- 2: Absolute path
    -- 3: Absolute path, with tilde as the home directory
    -- 4: Filename and parent dir, with tilde as the home directory

    shorting_target = 40, -- Shortens path to leave 40 spaces in the window
    -- for other components. (terrible name, any suggestions?)
    -- symbols = {
    --     modified = '[+]',      -- Text to show when the file is modified.
    --     readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
    --     unnamed = '[No Name]', -- Text to show for unnamed buffers.
    --     newfile = '[New]',     -- Text to show for newly created file before first write
    -- }
}

-- ins_left {
--     'diff',
--     -- Is it me or the symbol for modified us really weird
--     symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
--     diff_color = {
--         added = { fg = colors.green },
--         modified = { fg = colors.orange },
--         removed = { fg = colors.red },
--     },
--     cond = conditions.hide_in_width,
-- }

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {
    function()
        return "%="
    end,
}

-- -- Add components to right sections
-- ins_right {
--     'o:encoding',       -- option component same as &encoding in viml
--     fmt = string.upper, -- I'm not sure why it's upper case either ;)
--     cond = conditions.hide_in_width,
--     color = { fg = colors.green, gui = 'bold' },
-- }

-- ins_right {
--     'fileformat',
--     fmt = string.upper,
--     icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
--     color = { fg = colors.green, gui = 'bold' },
-- }

-- ins_right {
--     -- filesize component
--     'filesize',
--     cond = conditions.buffer_not_empty,
-- }



ins_right {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.yellow },
        color_info = { fg = colors.cyan },
    },
}

ins_right {
    function()
        local msg = ""
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                if msg == "" then
                    msg = client.name
                else
                    msg = msg .. ", " .. client.name
                end
            end
        end
        return msg
    end,
    icon = "",
    color = { fg = colors.violet, gui = "bold" },
}

-- ins_right {
--     'filetype',
--     color = { fg = colors.blue, gui = 'bold' }
-- }


-- ins_right {
--     "location",
--     color = { fg = colors.orange, gui = "bold" }
-- }

-- ins_right {
--     "progress",
--     color = { fg = colors.green, gui = 'bold' }
-- }


-- ins_right {
--     function()
--         return "▊"
--     end,
--     color = { fg = colors.violet },
--     padding = { left = 1 },
-- }

lualine.setup(options)
