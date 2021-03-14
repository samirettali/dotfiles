if vim.g.vscode then
  print("VSCode detected, loading custom settings")
  return
end

-- Load plugins
require 'samir.plugins'

require 'samir.utils.remaps'

-- Load settings
require 'samir.defaults'
require 'samir.lsp'

-- Load plugins settings
require 'samir.autopairs'
require 'samir.barbar'
require 'samir.camelcasemotion'
require 'samir.colorizer'
require 'samir.compe'
require 'samir.gitsigns'
require 'samir.highlightedundo'
require 'samir.illuminate'
require 'samir.indentline'
require 'samir.lualine'
require 'samir.matchtag'
require 'samir.oscyank'
require 'samir.ripgrep'
require 'samir.scalpel'
require 'samir.sneak'
require 'samir.telescope'
require 'samir.tree'
require 'samir.treesitter'
require 'samir.vimgo'
require 'samir.vsnip'

-- Vimscript stuff
require 'samir.vimscript'
