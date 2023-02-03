local present, lualine = pcall(require, "lualine")
if not present then
    return
end

local gps_present, gps = pcall(require, "nvim-gps")
if not gps_present then
    return
end

-- local function lsp_progress(_, is_active)
--     if not is_active then
--         return
--     end
--     local messages = vim.lsp.util.get_progress_messages()
--
--     if #messages == 0 then
--         return ""
--     end
--
--     local status = {}
--
--     for _, msg in pairs(messages) do
--         local title = ""
--         if msg.title then
--             title = msg.title
--         end
--         table.insert(status, (msg.percentage or 0) .. "%% " .. title)
--     end
--     local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
--     local ms = vim.loop.hrtime() / 1000000
--     local frame = math.floor(ms / 120) % #spinners
--     return table.concat(status, "  ") .. " " .. spinners[frame + 1]
-- end

local colors = {
    color0 = '#1c1c1c',
    color1 = '#ff5189',
    color2 = '#c6c6c6',
    color3 = '#303030',
    color4 = '#181818',
    color6 = '#9e9e9e',
    color7 = '#80a0ff',
    color8 = '#ae81ff',
}

local theme = {
    replace = {
        a = { fg = colors.color0, bg = colors.color1, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
    inactive = {
        a = { fg = colors.color6, bg = colors.color3, gui = 'bold' },
        b = { fg = colors.color6, bg = colors.color3 },
        c = { fg = colors.color6, bg = colors.color4 },
    },
    normal = {
        a = { fg = colors.color0, bg = colors.color7, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
        c = { fg = colors.color2, bg = colors.color4 },
    },
    visual = {
        a = { fg = colors.color0, bg = colors.color8, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
    insert = {
        a = { fg = colors.color0, bg = colors.color2, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
}

local options = {
    options = {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = "",
        icons_enabled = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { "branch" },
        lualine_c = {
            -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            { "diagnostics", sources = { "nvim_diagnostic" } }
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
    },
}

lualine.setup(options)
--
-- -- Using Lualine as the statusline.

-- Show git status.
-- local function diff_source()
--     local gitsigns = vim.b.gitsigns_status_dict
--     if gitsigns then
--         return {
--             added = gitsigns.added,
--             modified = gitsigns.changed,
--             removed = gitsigns.removed
--         }
--     end
-- end
--
-- -- Get the current buffer's filetype.
-- local function get_current_filetype()
--     return vim.api.nvim_buf_get_option(0, 'filetype')
-- end
--
-- -- Get the current buffer's type.
-- local function get_current_buftype()
--     return vim.api.nvim_buf_get_option(0, 'buftype')
-- end
--
-- -- Get the buffer's filename.
-- local function get_current_filename()
--     local bufname = vim.api.nvim_buf_get_name(0)
--     return bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'
-- end
--
-- -- Gets the current buffer's filename with the filetype icon supplied
-- -- by devicons.
-- local M = require('lualine.components.filetype'):extend()
-- Icon_hl_cache = {}
-- local lualine_require = require('lualine_require')
-- local modules = lualine_require.lazy_require {
--     highlight = 'lualine.highlight',
--     utils = 'lualine.utils.utils',
-- }
--
-- -- Return the current buffer's filetype icon with highlighting.
-- function M:get_current_filetype_icon()
--
--     -- Get setup.
--     local icon, icon_highlight_group
--     local _, devicons = pcall(require, 'nvim-web-devicons')
--     local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
--     f_extension = f_extension ~= '' and f_extension or vim.bo.filetype
--     icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)
--
--     -- Fallback settings.
--     if icon == nil and icon_highlight_group == nil then
--         icon = ''
--         icon_highlight_group = 'DevIconDefault'
--     end
--
--     -- Set colors.
--     local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
--     if highlight_color then
--         local default_highlight = self:get_default_hl()
--         local icon_highlight = Icon_hl_cache[highlight_color]
--         if not icon_highlight or not modules.highlight.highlight_exists(icon_highlight.name .. '_normal') then
--             icon_highlight = self:create_hl({ fg = highlight_color }, icon_highlight_group)
--             Icon_hl_cache[highlight_color] = icon_highlight
--         end
--         icon = self:format_hl(icon_highlight) .. icon .. default_highlight
--     end
--
--     -- Return the formatted string.
--     return icon
--
-- end
--
-- -- Return the current buffer's filename with the filetype icon.
-- function M:get_current_filename_with_icon()
--
--     -- Get icon and filename.
--     local icon = M.get_current_filetype_icon(self)
--     local f_name = get_current_filename()
--
--     -- Add readonly icon.
--     local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
--     local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
--     local nofile = get_current_buftype() == 'nofile'
--     if readonly or nofile or not modifiable then
--         f_name = f_name .. ' '
--     end
--
--     -- Return the formatted string.
--     return icon .. ' ' .. f_name .. ' '
--
-- end
--
-- -- Get the lsp of the current buffer, when using native lsp.
-- local function get_native_lsp()
--     local buf_ft = get_current_filetype()
--     local clients = vim.lsp.get_active_clients()
--     if next(clients) == nil then
--         return 'None'
--     end
--     for _, client in ipairs(clients) do
--         local filetypes = client.config.filetypes
--         if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
--             return client.name
--         end
--     end
--     return 'None'
-- end
--
-- -- Get the status of the compiler, if applicable.
-- local function get_compiler_status()
--     local filetype = get_current_filetype()
--     if filetype == 'tex' then
--         return ''
--     end
--     return ''
-- end
--
-- -- Display the difference in commits between local and head.
-- local Job = require 'plenary.job'
-- local function get_git_compare()
--
--     -- Get the path of the current directory.
--     local curr_dir = vim.api.nvim_buf_get_name(0):match("(.*" .. '/' .. ")")
--
--     -- Run job to get git.
--     local result = Job:new({
--         command = 'git',
--         cwd = curr_dir,
--         args = { 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' },
--     }):sync(100)[1]
--
--     -- Process the result.
--     if type(result) ~= 'string' then return '' end
--     local ok, ahead, behind = pcall(string.match, result, "(%d+)%s*(%d+)")
--     if not ok then return '' end
--
--     -- No file, so no git.
--     if get_current_buftype() == 'nofile' then
--         return ''
--     end
--
--     -- Format for lualine.
--     return ' ' .. behind .. '  ' .. ahead
--
-- end
--
-- -- Required to properly set the colors.
-- local c = require 'nordic.colors'
--
-- require 'lualine'.setup {
--     sections = {
--         lualine_a = {
--             {
--                 'mode',
--                 icon = { ' ' },
--             },
--         },
--         lualine_b = {
--             {
--                 M.get_current_filename_with_icon
--             },
--         },
--         lualine_c = {
--             {
--                 'branch',
--                 icon = {
--                     '',
--                     color = { fg = c.orange.bright, gui = 'bold' },
--                 },
--                 separator = ' ',
--             },
--             {
--                 get_git_compare,
--                 separator = ' ',
--                 icon = {
--                     ' ',
--                     color = { fg = c.orange.bright, gui = 'bold' },
--                 }
--             },
--             {
--                 'diff',
--                 colored = true,
--                 source = diff_source,
--                 symbols = {
--                     added = ' ',
--                     modified = ' ',
--                     removed = ' '
--                 },
--                 diff_color = {
--                     added = { fg = c.git.add, gui = 'bold' },
--                     modified = { fg = c.git.change, gui = 'bold' },
--                     removed = { fg = c.git.delete, gui = 'bold' },
--                 }
--                 -- icon = {
--                 -- ' ',
--                 -- color = { fg = get_color('Orange', 'fg') },
--                 -- }
--             },
--         },
--         lualine_x = {
--             {
--                 'diagnostics',
--                 sources = { 'nvim_diagnostic' },
--                 separator = '',
--                 symbols = {
--                     error = ' ',
--                     warn = ' ',
--                     info = ' ',
--                     hint = ' ',
--                 },
--                 diagnostics_color = {
--                     error = { fg = c.error, gui = 'bold' },
--                     warn = { fg = c.warn, gui = 'bold' },
--                     info = { fg = c.info, gui = 'bold' },
--                     hint = { fg = c.hint, gui = 'bold' },
--                 },
--                 colored = true,
--             },
--         },
--         lualine_y = {
--             -- {
--             --     get_compiler_status,
--             --     icon = {
--             --         ' ,',
--             --         align = 'left',
--             --         color = {
--             --             fg = c.orange.bright,
--             --             gui = 'bold'
--             --         }
--             --     },
--             --     separator = ''
--             -- },
--             -- {
--             --     get_native_lsp,
--             --     icon = {
--             --         '  ',
--             --         align = 'left',
--             --         color = {
--             --             fg = c.orange.bright,
--             --             gui = 'bold'
--             --         }
--             --     }
--             -- },
--         },
--         lualine_z = {
--             {
--                 'location',
--                 icon = {
--                     '',
--                     align = 'left',
--                     color = { fg = c.black },
--                 }
--             },
--             {
--                 'progress',
--                 icon = {
--                     '',
--                     align = 'left',
--                     color = { fg = c.black },
--                 }
--             }
--         },
--     },
--     options = {
--         disabled_filetypes = { "dashboard" },
--         globalstatus = true,
--         section_separators = { left = ' ', right = ' ' },
--         component_separators = { left = '', right = '' },
--         theme = "nordic",
--     },
--     extensions = {
--         "toggleterm",
--         "nvim-tree"
--     }
-- }
