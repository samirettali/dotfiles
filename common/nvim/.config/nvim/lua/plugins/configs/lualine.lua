local present, lualine = pcall(require, "lualine")
if not present then
    return
end

local gps = require("nvim-gps")

gps.setup({
  icons = {
    ["class-name"] = " ",      -- Classes and class-like objects
    ["function-name"] = " ",   -- Functions
    ["method-name"] = " "      -- Methods (functions inside class-like objects)
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
  separator = " > ",
})

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
  symbols = {added = "+", modified = "~", removed = "-"},
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
    gps.get_location,
    cond = gps.is_available
}

local options = {
  options = {
    theme = "base16",
    icons_enabled = true,
    component_separators = { left = "", right = ""},
    section_separators = { left = "", right = "" },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = { "mode" },
    -- lualine_b = { diff_component },
    lualine_b = { "branch", "diff", diagnostic_component },
    lualine_c = { "filename",  gps_component },
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
