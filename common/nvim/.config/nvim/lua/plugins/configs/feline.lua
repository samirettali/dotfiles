local vi_mode = require('feline.providers.vi_mode')
local git = require('feline.providers.git')
local lsp = require('feline.providers.lsp')
local gps = require('nvim-gps')

gps.setup()

local components = { active = {}, inactive = {} }

-- Active statusline
components.active[1] = {
    {
        provider = 'vi_mode',
        icon = '',
        hl = function()
            return {
                fg = "fg",
                bg = 'darkgreen',
                style = 'bold'
            }
        end,
        left_sep = {
            {
                str = ' ',
                hl = { bg = 'darkgreen' }
            }
        },
        right_sep = {
            {
                str = ' ',
                hl = { bg = 'gray' }
            },
            {
                str = 'slant_right_2',
                hl = { fg = 'gray' }
            },
            -- '  '
        },
    },
    {
        hl = function()
            return {
                fg = vi_mode.get_mode_color(),
                bg = '#1e1e2e',
                style = 'bold'
            }
        end,
        provider = 'git_branch',
        left_sep = 'slant_left',
        right_sep = 'slant_right_2'
    },
    {
        hl = function()
            return {
                fg = vi_mode.get_mode_color(),
                bg = 'gray',
                style = 'bold'
            }
        end,
        enabled = function()
            return vim.bo.filetype ~= ''
        end,
        provider = {
            name = 'file_type',
            opts = {
                case = 'titlecase',
                filetype_icon = true,
                colored_icon = false
            }
        },
        left_sep = ' ',
        right_sep = '  '
    },
    {
        enabled = function()
            return gps.is_available()
        end,
        provider = function()
            return gps.get_location()
        end,
        hl = {
            fg = 'white',
        },
    }
}

components.active[2] = {
    {
        provider = {
            name = 'file_info',
            opts = {
                type = 'unique',
                colored_icon = false
            }
        },
        right_sep = '  '
    },
    {
        provider = {
            name = 'position',
            opts = {
                format = 'Ln {line}, Col {col}'
            }
        },
        right_sep = ' '
    },
    {
        provider = 'git_diff_added',
    },
    {
        provider = 'git_diff_changed',
    },
    {
        provider = 'git_diff_removed',
    },
    {
        enabled = function()
            return git.git_info_exists()
        end,
        right_sep = { str = ' ', always_visible = true }
    },
    {
        provider = 'diagnostic_errors',
    },
    {
        provider = 'diagnostic_warnings',
    },
    {
        provider = 'diagnostic_hints',
    },
    {
        provider = 'diagnostic_info',
    },
    {
        enabled = function()
            return lsp.diagnostics_exist()
        end,
        right_sep = { str = ' ', always_visible = true }
    }
}

components.inactive[1] = {
    {
        enabled = function()
            return vim.bo.filetype ~= ''
        end,
        provider = {
            name = 'file_type',
            opts = {
                case = 'titlecase',
                filetype_icon = true,
                colored_icon = false
            }
        },
        left_sep = ' ',
        right_sep = '  '
    },
    {
        provider = 'vi_mode',
        icon = '',
        hl = function()
            return {
                fg = vi_mode.get_mode_color(),
                bg = 'gray',
                style = 'bold'
            }
        end,
        left_sep = {
            {
                str = 'left_filled',
                hl = { fg = 'gray' }
            },
            {
                str = ' ',
                hl = { bg = 'gray' }
            }
        },
        right_sep = {
            {
                str = ' ',
                hl = { bg = 'gray' }
            },
            {
                str = 'right_filled',
                hl = { fg = 'gray' }
            },
        },
    },
}

components.inactive[2] = {
    {
        provider = {
            name = 'position',
            opts = {
                format = 'Ln {line}, Col {col}'
            }
        },
        right_sep = ' '
    }
}

-- Setup feline.nvim
require('feline').setup {
    components = components,
    theme = {
        lightgray = 'Gray',
        gray = 'DarkGray',
        bg = '#0F0F0F',
        fg = "Comment",
        yellow = '#e5c07b',
        cyan = '#8abeb7',
        darkblue = '#528bff',
        green = '#98c379',
        orange = '#d19a66',
        darkpurple = '#b294bb',
        purple = '#ff80ff',
        blue = '#61afef';
        red = '#e88388';
    },
    force_inactive = {
        filetypes = {
            '^NvimTree$',
            '^packer$',
            '^startify$',
            '^fugitive$',
            '^fugitiveblame$',
            '^qf$',
            '^help$',
        },
        buftypes = {
            '^terminal$',
            '^nofile$'
        },
    },
}

local winbar_components = {
    active = {
        {
            {
                provider = 'file_info',
                hl = {
                    fg = 'skyblue',
                    bg = 'NONE',
                    style = 'bold',
                },
            },
        },
    },
    inactive = {
        {
            {
                provider = 'file_info',
                hl = {
                    fg = 'white',
                    bg = 'NONE',
                    style = 'bold',
                },
            },
        },
    },
}


require('feline').winbar.setup {
    components = winbar_components,
}
