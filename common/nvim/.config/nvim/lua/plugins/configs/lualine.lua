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
  colored = true,
  diff_color = {
    added    = 'DiffAdd',    -- Changes the diff's added color
    modified = 'DiffChange', -- Changes the diff's modified color
    removed  = 'DiffDelete', -- Changes the diff's removed color you
  },
  condition = conditions.hide_in_width
}

local diagnostic_component =  {
  'diagnostics',
  sources = {'nvim_lsp'},
  symbols = {error = ' ', warn = ' ', info = ' '},
}

local function gps_location()
  if gps.is_available() then
    return gps.get_location()
  else
    return ""
  end
end

-- local function obsession()
--    return vim.api.nvim_eval('ObsessionStatus("$", "S")')
-- end

local config = {
  options = {
    theme = 'moonfly',
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = { { 'mode', upper = true } },
    -- lualine_b = { obsession, diff_component },
    lualine_b = { diff_component },
    lualine_c = { gps_location, diagnostic_component },
    lualine_x = { 'filename' },
    lualine_y = { 'location'  },
    lualine_z = { { 'branch', icon = '' } },
  },
  inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = {  },
    lualine_x = { 'location' },
    lualine_y = { { 'filename', condition = conditions.buffer_not_empty } },
    lualine_z = {   }
  },
}

lualine.setup(config)

