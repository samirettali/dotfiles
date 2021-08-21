local base16 = require 'base16'
local colors = require('samir.themes.' .. vim.g.nvchad_theme)

local gl = require("galaxyline")

local condition = require "galaxyline.condition"
local gls = gl.section
gl.short_line_list = {"LuaTree", "packer", "Floaterm", "vista", "NvimTree"}


local function get_mode_name()
  local names = {
    n = "NORMAL",
    i = "INSERT",
    c = "COMMAND",
    v = "VISUAL",
    V = "VISUAL LINE",
    t = "TERMINAL",
    R = "REPLACE",
    [""] = "VISUAL BLOCK",
  }
  return names[vim.fn.mode()]
end

table.insert(gls.left, {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {
        n = colors.blue,
        i = colors.green,
        v = colors.purple,
        [""] = colors.purple,
        V = colors.purple,
        c = colors.pink,
        no = colors.blue,
        s = colors.orange,
        S = colors.orange,
        [""] = colors.orange,
        ic = colors.yellow,
        R = colors.red,
        Rv = colors.red,
        cv = colors.blue,
        ce = colors.blue,
        r = colors.cyan,
        rm = colors.teal,
        ["r?"] = colors.teal,
        ["!"] = colors.blue,
        t = colors.blue,
      }
      local name = get_mode_name()
      -- Fall back to the default behavior is a name is not defined
      if name ~= nil then
        vim.api.nvim_command("hi GalaxyViMode guibg=" .. mode_color[vim.fn.mode()])
        vim.api.nvim_command("hi GalaxyViMode guifg=" .. colors.one_bg)
        return "  " .. name .. " "
      end
      vim.api.nvim_command("hi GalaxyViMode guibg=" .. colors.one_bg)
      vim.api.nvim_command("hi GalaxyViMode guifg=" .. mode_color[vim.fn.mode()])
      return "▊"
    end,
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { "NONE", colors.one_bg },
  },
})
-- print(vim.fn.getbufvar(0, 'ts'))
vim.fn.getbufvar(0, "ts")

table.insert(gls.left, {
  GitIcon = {
    provider = function()
      return "  "
    end,
    condition = condition.check_git_workspace,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.orange, colors.one_bg },
  },
})

table.insert(gls.left, {
  GitBranch = {
    provider = "GitBranch",
    condition = condition.check_git_workspace,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.left, {
  DiffAdd = {
    provider = "DiffAdd",
    condition = condition.hide_in_width,
    icon = "  ",
    highlight = { colors.green, colors.one_bg },
  },
})

table.insert(gls.left, {
  DiffModified = {
    provider = "DiffModified",
    condition = condition.hide_in_width,
    icon = " 柳",
    highlight = { colors.blue, colors.one_bg },
  },
})

table.insert(gls.left, {
  DiffRemove = {
    provider = "DiffRemove",
    condition = condition.hide_in_width,
    icon = "  ",
    highlight = { colors.red, colors.one_bg },
  },
})

table.insert(gls.left, {
  Filler = {
    provider = function()
      return " "
    end,
    highlight = { colors.white, colors.one_bg },
  },
})
-- get output from shell command
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read "*a")
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end
-- cleanup virtual env
local function env_cleanup(venv)
  if string.find(venv, "/") then
    local final_venv = venv
    for w in venv:gmatch "([^/]+)" do
      final_venv = w
    end
    venv = final_venv
  end
  return venv
end
local PythonEnv = function()
  if vim.bo.filetype == "python" then
    local venv = os.getenv "CONDA_DEFAULT_ENV"
    if venv ~= nil then
      return "  (" .. env_cleanup(venv) .. ")"
    end
    venv = os.getenv "VIRTUAL_ENV"
    if venv ~= nil then
      return "  (" .. env_cleanup(venv) .. ")"
    end
    return ""
  end
  return ""
end
table.insert(gls.left, {
  VirtualEnv = {
    provider = PythonEnv,
    event = "BufEnter",
    highlight = { colors.green, colors.one_bg },
  },
})

table.insert(gls.right, {
  DiagnosticError = {
    provider = "DiagnosticError",
    icon = "  ",
    highlight = { colors.red, colors.one_bg },
  },
})
table.insert(gls.right, {
  DiagnosticWarn = {
    provider = "DiagnosticWarn",
    icon = "  ",
    highlight = { colors.orange, colors.one_bg },
  },
})

table.insert(gls.right, {
  DiagnosticInfo = {
    provider = "DiagnosticInfo",
    icon = "  ",
    highlight = { colors.yellow, colors.one_bg },
  },
})

table.insert(gls.right, {
  DiagnosticHint = {
    provider = "DiagnosticHint",
    icon = "  ",
    highlight = { colors.blue, colors.one_bg },
  },
})

table.insert(gls.right, {
  TreesitterIcon = {
    provider = function()
      if next(vim.treesitter.highlighter.active) ~= nil then
        return "  "
      end
      return ""
    end,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.green, colors.one_bg },
  },
})

local function get_attached_provider_name(msg)
  msg = msg or "LSP Inactive"

  local buf_clients = vim.lsp.buf_get_clients()
  if next(buf_clients) == nil then
    return msg
  end

  local buf_client_names = {}
  for _, client in pairs(buf_clients) do
    if client.name ~= "null-ls" then
      table.insert(buf_client_names, client.name)
    end
  end

  local null_ls = require "samir.null-ls"
  local null_ls_providers = null_ls.list_supported_provider_names(vim.bo.filetype)
  vim.list_extend(buf_client_names, null_ls_providers)

  return table.concat(buf_client_names, ", ")
end

table.insert(gls.right, {
  ShowLspClient = {
    provider = get_attached_provider_name,
    condition = function()
      local tbl = { ["dashboard"] = true, [" "] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = " ",
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  LineInfo = {
    provider = "LineColumn",
    separator = "  ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  PerCent = {
    provider = "LinePercent",
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  Tabstop = {
    provider = function()
      local label = "Spaces: "
      if not vim.api.nvim_buf_get_option(0, "expandtab") then
        label = "Tab size: "
      end
      return label .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. " "
    end,
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  BufferType = {
    provider = "FileTypeName",
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  FileEncode = {
    provider = "FileEncode",
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.right, {
  Space = {
    provider = function()
      return " "
    end,
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.white, colors.one_bg },
  },
})

table.insert(gls.short_line_left, {
  BufferType = {
    provider = "FileTypeName",
    separator = " ",
    separator_highlight = { "NONE", colors.one_bg },
    highlight = { colors.one_bg, colors.one_bg },
  },
})

table.insert(gls.short_line_left, {
  SFileName = {
    provider = "SFileName",
    condition = condition.buffer_not_empty,
    highlight = { colors.one_bg, colors.one_bg },
  },
})

--table.insert(gls.short_line_right[1] = {BufferIcon = {provider = 'BufferIcon', highlight = {colors.white, colors.one_bg}}})
