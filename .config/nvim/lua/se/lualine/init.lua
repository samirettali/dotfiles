local lualine = require('lualine')

lualine.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'modified' },
  lualine_c = {  },
  lualine_x = { 'location' },
  lualine_y = { 'progress' },
  lualine_z = { 'fileformat' },
  lualine_diagnostics = {  }
}

lualine.inactiveSections = {
  lualine_a = {  },
  lualine_b = {  },
  lualine_c = {  },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {  }
}

lualine.status()
