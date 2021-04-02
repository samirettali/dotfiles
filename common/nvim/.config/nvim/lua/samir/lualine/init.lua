function lspStatus()
  if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    local indicators = {}

    local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
    if error_count > 0 then
      table.insert(indicators, "E: " .. error_count)
    end

    local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    if warning_count > 0 then
      table.insert(indicators, "W: " .. warning_count)
    end

    local info_count = vim.lsp.diagnostic.get_count(0, 'Information')
    if info_count > 0 then
      table.insert(indicators, "I: " .. info_count)
    end

    local hint_count = vim.lsp.diagnostic.get_count(0, 'Hint')
    if hint_count > 0 then
      table.insert(indicators, "H: " .. hint_count)
    end

    return table.concat(indicators, ' / ')
  else
    return ''
  end
end

local colors = {
  color3   = "#1c1c1c",
  color6   = "#b2b2b2",
  color7   = "#82aaff",
  color8   = "#d183e8",
  color0   = "#373c40",
  color1   = "#ff5454",
  color2   = "#eeeeee",
  color9   = "#8cc85f",
}

local moonfly = {
  replace = {
    a = { fg = colors.color0, bg = colors.color1 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  inactive = {
    a = { fg = colors.color6, bg = colors.color3 , "bold", },
    b = { fg = colors.color6, bg = colors.color3 },
    c = { fg = colors.color6, bg = colors.color3 },
  },
  normal = {
    a = { fg = colors.color0, bg = colors.color7 , "bold", },
    b = { fg = colors.color2, bg = colors.color0 },
    c = { fg = colors.color2, bg = colors.color3 },
  },
  visual = {
    a = { fg = colors.color0, bg = colors.color8 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  insert = {
    a = { fg = colors.color0, bg = colors.color9 , "bold", },
    b = { fg = colors.color2, bg = colors.color0 },
  },
}

local function obsession()
   return vim.api.nvim_eval('ObsessionStatus("$", "S")')
end

require('lualine').setup{
  options = {
    theme = moonfly,
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = { {'mode', upper = true} },
    lualine_b = { {'branch', icon = ''} },
    lualine_c = { {'filename', file_status = true, full_path = true}, obsession },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location'  },
  },
  inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = { {'filename', full_path = true} },
    lualine_x = { 'location' },
    lualine_y = {  },
    lualine_z = {   }
  },
}
