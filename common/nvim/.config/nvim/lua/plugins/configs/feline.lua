local present, feline = pcall(require, "feline")

if not present then
   return
end

local options = {
   colors = require("base46").get_colors "base_30",
   lsp = require "feline.providers.lsp",
   lsp_severity = vim.diagnostic.severity,
}

local gps = require('nvim-gps')

local colors = {
    black     = '#080808',
    white     = '#c6c6c6',
    grey0     = '#323437',
    grey254   = '#e4e4e4',
    grey249   = '#b2b2b2',
    grey247   = '#9e9e9e',
    grey246   = '#949494',
    grey244   = '#808080',
    grey241   = '#626262',
    grey237   = '#3a3a3a',
    grey236   = '#303030',
    grey235   = '#262626',
    grey234   = '#1c1c1c',
    grey233   = '#121212',
    khaki     = '#c2c292',
    yellow    = '#e3c78a',
    orange    = '#de935f',
    coral     = '#f09479',
    lime      = '#85dc85',
    green     = '#8cc85f',
    emerald   = '#36c692',
    blue      = '#80a0ff',
    sky       = '#74b2ff',
    turquoise = '#79dac8',
    purple    = '#ae81ff',
    cranberry = '#e2637f',
    violet    = '#d183e8',
    crimson   = '#ff5189',
    red       = '#ff5454',
    spring    = '#00875f',
}



gps.setup({
	icons = {
		['class-name'] = ' ',      -- Classes and class-like objects
		['function-name'] = ' ',   -- Functions
		['method-name'] = ' '      -- Methods (functions inside class-like objects)
	},
	languages = {                    -- You can disable any language individually here
		['c'] = true,
		['cpp'] = true,
		['go'] = true,
		['java'] = true,
		['javascript'] = true,
		['lua'] = true,
		['python'] = true,
		['rust'] = true,
	},
	separator = ' > ',
})

local icon_styles = {
   default = {
      left = '',
      right = ' ',
      main_icon = '  ',
      vi_mode_icon = ' ',
      position_icon = ' ',
   },
   arrow = {
      left = '',
      right = '',
      main_icon = '  ',
      vi_mode_icon = ' ',
      position_icon = ' ',
   },

   block = {
      left = ' ',
      right = ' ',
      main_icon = '   ',
      vi_mode_icon = '  ',
      position_icon = '  ',
   },

   round = {
      left = '',
      right = '',
      main_icon = '  ',
      vi_mode_icon = ' ',
      position_icon = ' ',
   },

   slant = {
      left = ' ',
      right = ' ',
      main_icon = '  ',
      vi_mode_icon = ' ',
      position_icon = ' ',
   },
}


-- default, round , slant , block , arrow
local user_statusline_style = 'default'
local statusline_style = icon_styles[user_statusline_style]

-- Initialize the components table
local components = {
   active = {},
   inactive = {},
}

-- Initialize left, mid and right
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})

components.active[1][1] = {
   provider = statusline_style.main_icon,

   hl = {
      fg = colors.statusline_bg,
      bg = colors.turquoise,
   },
   
   right_sep = {
      str = statusline_style.right,
      hl = {
        fg = colors.turquoise,
        bg = colors.one_bg2,
      }
   },
}

components.active[1][2] = {
   provider = statusline_style.right,

   hl = {
      fg = colors.one_bg2,
      bg = colors.lightbg,
   },
}

components.active[1][3] = {
   provider = function()
      local filename = vim.fn.expand '%:t'
      local extension = vim.fn.expand '%:e'
      local icon = require('nvim-web-devicons').get_icon(filename, extension)
      if icon == nil then
         icon = ''
         return icon
      end
      return icon .. ' ' .. filename .. ' '
   end,
   hl = {
      fg = colors.white,
      bg = colors.lightbg,
   },

   right_sep = { str = statusline_style.right, hl = { fg = colors.lightbg, bg = colors.lightbg2 } },
}

components.active[1][4] = {
   provider = function()
      local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
      return '  ' .. dir_name .. ' '
   end,

   hl = {
      fg = colors.grey_fg2,
      bg = colors.lightbg2,
   },
   right_sep = { str = statusline_style.right, hi = {
      fg = colors.lightbg2,
      bg = colors.statusline_bg,
   } },
}

components.active[1][5] = {
   provider = 'git_diff_added',
   hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
   },
   icon = ' ',
}
-- diffModfified
components.active[1][6] = {
   provider = 'git_diff_changed',
   hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
   },
   icon = '   ',
}
-- diffRemove
components.active[1][7] = {
   provider = 'git_diff_removed',
   hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
   },
   icon = '  ',
}

components.active[1][8] = {
   provider = 'diagnostic_errors',
   enabled = lsp.diagnostics_exist(vim.diagnostic.severity.ERROR),
   hl = { fg = colors.red },
   icon = '  ',
}

components.active[1][9] = {
   provider = 'diagnostic_warnings',
   enabled = lsp.diagnostics_exist(vim.diagnostic.severity.WARN),
   hl = { fg = colors.yellow },
   icon = '  ',
}

components.active[1][10] = {
   provider = 'diagnostic_hints',
   enabled = lsp.diagnostics_exist(vim.diagnostic.severity.HINT),
   hl = { fg = colors.grey_fg2 },
   icon = '  ',
}

components.active[1][11] = {
   provider = 'diagnostic_info',
   enabled = lsp.diagnostics_exist(vim.diagnostic.severity.INFO),
   hl = { fg = colors.green },
   icon = '  ',
}

components.active[1][12] = {
   provider = gps.get_location,
   enabled = function()
      return gps.is_available()
   end,
   icon = '  ',
   hl = { fg = colors.green },
}

components.active[2][1] = {
   provider = function()
      local Lsp = vim.lsp.util.get_progress_messages()[1]
      if Lsp then
         local msg = Lsp.message or ''
         local percentage = Lsp.percentage or 0
         local title = Lsp.title or ''
         local spinners = {
            '',
            '',
            '',
         }

         local success_icon = {
            '',
            '',
            '',
         }

         local ms = vim.loop.hrtime() / 1000000
         local frame = math.floor(ms / 120) % #spinners

         if percentage >= 70 then
            return string.format(' %%<%s %s %s (%s%%%%) ', success_icon[frame + 1], title, msg, percentage)
         else
            return string.format(' %%<%s %s %s (%s%%%%) ', spinners[frame + 1], title, msg, percentage)
         end
      end
      return ''
   end,
   hl = { fg = colors.green },
}

components.active[3][1] = {
   provider = function()
      if next(vim.lsp.buf_get_clients()) ~= nil then
         return ' LSP'
      else
         return ''
      end
   end,
   hl = { fg = colors.grey_fg2, bg = colors.statusline_bg },
}

components.active[3][2] = {
   provider = 'git_branch',
   hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
   },
   icon = '  ',
}

components.active[3][3] = {
   provider = ' ' .. statusline_style.left,
   hl = {
      fg = colors.one_bg2,
      bg = colors.statusline_bg,
   },
}

local mode_colors = {
   ['n'] = { 'NORMAL', colors.red },
   ['no'] = { 'N-PENDING', colors.red },
   ['i'] = { 'INSERT', colors.purple },
   ['ic'] = { 'INSERT', colors.purple },
   ['t'] = { 'TERMINAL', colors.green },
   ['v'] = { 'VISUAL', colors.cyan },
   ['V'] = { 'V-LINE', colors.cyan },
   [''] = { 'V-BLOCK', colors.cyan },
   ['R'] = { 'REPLACE', colors.orange },
   ['Rv'] = { 'V-REPLACE', colors.orange },
   ['s'] = { 'SELECT', colors.turquoise },
   ['S'] = { 'S-LINE', colors.turquoise },
   [''] = { 'S-BLOCK', colors.turquoise },
   ['c'] = { 'COMMAND', colors.pink },
   ['cv'] = { 'COMMAND', colors.pink },
   ['ce'] = { 'COMMAND', colors.pink },
   ['r'] = { 'PROMPT', colors.sky },
   ['rm'] = { 'MORE', colors.sky },
   ['r?'] = { 'CONFIRM', colors.sky },
   ['!'] = { 'SHELL', colors.green },
}

local chad_mode_hl = function()
   return {
      fg = mode_colors[vim.fn.mode()][2],
      bg = colors.one_bg,
   }
end

components.active[3][4] = {
   provider = statusline_style.left,
   hl = function()
      return {
         fg = mode_colors[vim.fn.mode()][2],
         bg = colors.one_bg2,
      }
   end,
}

components.active[3][5] = {
   provider = statusline_style.vi_mode_icon,
   hl = function()
      return {
         fg = colors.statusline_bg,
         bg = mode_colors[vim.fn.mode()][2],
      }
   end,
}

components.active[3][6] = {
   provider = function()
      return ' ' .. mode_colors[vim.fn.mode()][1] .. ' '
   end,
   hl = chad_mode_hl,
}

components.active[3][7] = {
   provider = statusline_style.left,
   hl = {
      fg = colors.grey,
      bg = colors.one_bg,
   },
}

components.active[3][8] = {
   provider = statusline_style.left,
   hl = {
      fg = colors.green,
      bg = colors.grey,
   },
}

components.active[3][9] = {
   provider = statusline_style.position_icon,
   hl = {
      fg = colors.black,
      bg = colors.green,
   },
}

components.active[3][10] = {
    provider = 'position',
    left_sep = ' ',
--    provider = function()
--       local current_line = vim.fn.line '.'
--       local total_line = vim.fn.line '$'
--
--       if current_line == 1 then
--          return ' Top '
--       elseif current_line == vim.fn.line '$' then
--          return ' Bot '
--       end
--       local result, _ = math.modf((current_line / total_line) * 100)
--       return ' ' .. result .. '%% '
--    end,
--
   hl = {
      fg = colors.green,
      bg = colors.one_bg,
   },
}

require('feline').setup {
   colors = {
      bg = colors.statusline_bg,
      fg = colors.fg,
   },
   components = components,
}
