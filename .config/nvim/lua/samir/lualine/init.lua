local lualine = require('lualine')

lualine.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'filename' },
  lualine_c = {  },
  lualine_x = { 'location' },
  lualine_y = { 'progress' },
  lualine_z = { 'filetype' },
  lualine_diagnostics = {  }
}

lualine.inactiveSections = {
  lualine_a = {  },
  lualine_b = { 'filename' },
  lualine_c = {  },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {  }
}

lualine.theme = 'default'

lualine.status()
