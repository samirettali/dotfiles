if vim.g.vscode then
  print("VSCode detected, loading custom settings")
  return
end

-- Load plugins
require 'samir.plugins'

require 'samir.utils.remaps'

-- Load settings
require 'samir.defaults'
require 'samir.highlights'
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

-- Vimscript stuff
require 'samir.vimscript'

require('package-info').setup()
