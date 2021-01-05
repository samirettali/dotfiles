local lualine = require('lualine')

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

lualine.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'filename' },
  lualine_c = { lspStatus },
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

lualine.theme = 'auto'

lualine.status()
