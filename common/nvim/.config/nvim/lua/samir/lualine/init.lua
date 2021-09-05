local lualine = require('lualine')
local gps = require('nvim-gps')

gps.setup({
	icons = {
		["class-name"] = ' ',      -- Classes and class-like objects
		["function-name"] = ' ',   -- Functions
		["method-name"] = ' '      -- Methods (functions inside class-like objects)
	},
	languages = {                    -- You can disable any language individually here
		["c"] = true,
		["cpp"] = true,
		["go"] = true,
		["java"] = true,
		["javascript"] = true,
		["lua"] = true,
		["python"] = true,
		["rust"] = true,
	},
	separator = ' > ',
})


local colors = {
  black = "#1c1c1c",
  lightGray = "#b2b2b2",
  blue = "#74b2ff",
  magenta = "#d183e8",
  darkGrey = "#373c40",
  red = "#ff5189",
  white = "#eeeeee",
  green = "#36c692",
  yellow = '#bfbf97',
  orange = '#f09479'
}

local conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end
}

local diff_component = {
  'diff',
  symbols = {added = '+', modified = '~', removed = '-'},
  color_added = colors.green,
  color_modified = colors.orange,
  color_removed = colors.red,
  condition = conditions.hide_in_width
}

local diagnostic_component =  {
  'diagnostics',
  sources = {'nvim_lsp'},
  symbols = {error = ' ', warn = ' ', info = ' '},
  color_error = colors.red,
  color_warn = colors.orange,
  color_info = colors.cyan
}

local function gps_location()
	if gps.is_available() then
		return gps.get_location()
	else
		return ""
	end
end

local config = {
  options = {
    theme = {
      replace = {
        a = { fg = colors.darkGrey, bg = colors.magenta , "bold", },
        b = { fg = colors.white, bg = colors.black },
      },
      inactive = {
        a = { fg = colors.lightGray, bg = colors.black , "bold", },
        b = { fg = colors.lightGray, bg = colors.black },
        c = { fg = colors.lightGray, bg = colors.black },
      },
      normal = {
        a = { fg = colors.darkGrey, bg = colors.blue , "bold", },
        b = { fg = colors.white, bg = colors.darkGrey },
        c = { fg = colors.white, bg = colors.black },
      },
      visual = {
        a = { fg = colors.darkGrey, bg = colors.red , "bold", },
        b = { fg = colors.white, bg = colors.black },
      },
      insert = {
        a = { fg = colors.darkGrey, bg = colors.green , "bold", },
        b = { fg = colors.white, bg = colors.darkGrey },
      },
    },
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = { { 'mode', upper = true } },
    lualine_b = { 'filename', obsession },
    lualine_c = { diff_component, gps_location, diagnostic_component },
    lualine_x = { 'progress' },
    lualine_y = { 'location'  },
    lualine_z = { { 'branch', icon = '' } },
  },
  inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = { { 'filename', condition = conditions.buffer_not_empty } },
    lualine_x = { 'location' },
    lualine_y = {  },
    lualine_z = {   }
  },
}

local function obsession()
   return vim.api.nvim_eval('ObsessionStatus("$", "S")')
end

lualine.setup(config)

