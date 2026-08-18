require("xeno").setup({
  background = "#000000",
  accent = "#00bbbb",
  properties = {
    contrast = 0.0,
    variation = 0.0,
    chroma = 0.0,
    lightness = 0.0,
  },
  transparent = false,
  foreground = "#bbbbbb",
  red = "#ff5555",
  green = "#55ff55",
  yellow = "#ffff55",
  orange = "#bb0000",
  blue = "#5555ff",
  purple = "#ff55ff",
  cyan = "#55ffff",
  highlights = {
    syntax = {
      Property = {
        fg = "@cyan"
      },
      ["@type"] = {
        link = "Type"
      },
      ["@number"] = {
        link = "Number"
      },
      Comment = {
        fg = "@foreground.400"
      },
      Number = {
        fg = "@yellow"
      },
      ["@operator"] = {
        link = "Operator"
      },
      Conditional = {
        fg = "@purple"
      },
      ["@string"] = {
        link = "String"
      },
      Keyword = {
        fg = "@purple"
      },
      Function = {
        fg = "@blue"
      },
      String = {
        fg = "@green"
      },
      Boolean = {
        fg = "@yellow"
      },
      Constant = {
        fg = "@orange"
      },
      ["@keyword.repeat"] = {
        link = "Conditional"
      },
      Type = {
        fg = "@cyan"
      },
      ["@keyword.conditional"] = {
        link = "Conditional"
      },
      ["@function"] = {
        link = "Function"
      },
      ["@property"] = {
        link = "Property"
      },
      ["@constant"] = {
        link = "Constant"
      },
      Operator = {
        fg = "@foreground.300"
      },
      ["@boolean"] = {
        link = "Boolean"
      },
      ["@keyword"] = {
        link = "Keyword"
      }
    }
  },
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "xeno-ansi"
