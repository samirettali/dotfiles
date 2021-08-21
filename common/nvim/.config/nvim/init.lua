if vim.g.vscode then
  print("VSCode detected, loading custom settings")
  return
end

lvim = {
  leader = "space",
  colorscheme = "spacegray",
  line_wrap_cursor_movement = true,
  transparent_window = false,
  format_on_save = true,
  vsnip_dir = os.getenv "HOME" .. "/.config/snippets",
  database = { save_location = "~/.config/lunarvim_db", auto_execute = 1 },
  keys = {},

  -- TODO why do we need this?
  builtin = {
    lspinstall = {},
    telescope = {},
    compe = {},
    autopairs = {},
    treesitter = {},
    nvimtree = {},
    gitsigns = {},
    which_key = {},
    comment = {},
    rooter = {},
    galaxyline = {},
    bufferline = {},
    dap = {},
    dashboard = {},
    terminal = {},
  },

  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "warn",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
      layout_config = {
        ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "horizontal",
        open_mapping = "",
        size = 40,
        float_opts = {},
      },
    },
  },

  lsp = {
    completion = {
      item_kind = {
        "   (Text) ",
        "   (Method)",
        "   (Function)",
        "   (Constructor)",
        " ﴲ  (Field)",
        "[] (Variable)",
        "   (Class)",
        " ﰮ  (Interface)",
        "   (Module)",
        " 襁 (Property)",
        "   (Unit)",
        "   (Value)",
        " 練 (Enum)",
        "   (Keyword)",
        "   (Snippet)",
        "   (Color)",
        "   (File)",
        "   (Reference)",
        "   (Folder)",
        "   (EnumMember)",
        " ﲀ  (Constant)",
        " ﳤ  (Struct)",
        "   (Event)",
        "   (Operator)",
        "   (TypeParameter)",
      },
    },
    diagnostics = {
      signs = {
        active = true,
        values = {
          { name = "LspDiagnosticsSignError", text = "" },
          { name = "LspDiagnosticsSignWarning", text = "" },
          { name = "LspDiagnosticsSignHint", text = "" },
          { name = "LspDiagnosticsSignInformation", text = "" },
        },
      },
      virtual_text = {
        prefix = "",
        spacing = 0,
      },
      underline = true,
      severity_sort = true,
    },
    override = {},
    document_highlight = true,
    popup_border = "single",
    on_attach_callback = nil,
    on_init_callback = nil,
    ---@usage query the project directory from the language server and use it to set the CWD
    smart_cwd = true,
  },

  plugins = {
    -- use config.lua for this not put here
  },

  autocommands = {},
}


-- Load plugins
require 'samir.plugins'

require 'samir.utils.remaps'

-- Load settings
require 'samir.defaults'
-- require 'samir.highlights'
require 'samir.lsp'
require 'samir.lspkind'

-- Load plugins settings
require 'samir.autopairs'
require 'samir.barbar'
require 'samir.camelcasemotion'
require 'samir.colorizer'
require 'samir.compe'
require 'samir.gitsigns'
require 'samir.go'
require 'samir.highlightedundo'
require 'samir.illuminate'
require 'samir.indentline'
require 'samir.lualine'
require 'samir.matchtag'
require 'samir.oscyank'
require 'samir.ripgrep'
require 'samir.scalpel'
require 'samir.scrollview'
require 'samir.sneak'
require 'samir.splitline'
require 'samir.telescope'
require 'samir.tree'
require 'samir.treesitter'
require 'samir.trouble'
require 'samir.vimgo'
require 'samir.vsnip'
require 'samir.dashboard'
require 'samir.vista'
require 'samir.gitblame'

-- Vimscript stuff
require 'samir.vimscript'

require('package-info').setup()
