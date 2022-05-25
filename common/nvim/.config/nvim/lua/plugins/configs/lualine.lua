local present, lualine = pcall(require, "lualine")
if not present then
    return
end

local conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand("%:t")) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end
}

local diff_component = {
  "diff",
  symbols = {
      added = "+",
      modified = "~",
      removed = "-"
  },
  colored = true,
  diff_color = {
    added    = "DiffAdd",    -- Changes the diff"s added color
    modified = "DiffChange", -- Changes the diff"s modified color
    removed  = "DiffDelete", -- Changes the diff"s removed color you
  },
  condition = conditions.hide_in_width
}

local diagnostic_component =  {
  "diagnostics",
  sources = { "nvim_lsp" },
  symbols = {
      error = " ",
      warn = " ",
      info = " "
  },
}

local gps_component = {
    fmt = function()
        local gps = require("nvim-gps")
        return gps.get_location()
    end,
    cond = function()
        local present, gps = pcall(require, "nvim-gps")
        if not present then
            return false
        end

        if not gps.is_available() then
            return false
        end
    end,
}

local options = {
  options = {
    theme = "base16",
    icons_enabled = true,
    -- component_separators = { left = "", right = ""},
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    -- lualine_b = { diff_component },
    lualine_b = { "branch", "diff", diagnostic_component },
    lualine_c = { "filename", gps_component },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress"  },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {  },
    lualine_b = {  },
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {  },
    lualine_z = {  }
  },
}

lualine.setup(options)
