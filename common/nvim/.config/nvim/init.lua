-- Load plugins
require 'samir.plugins'

require 'samir.utils.remaps'

-- Load settings
require 'samir.defaults'
require('samir.colors').init()
require 'samir.lsp'
require 'samir.lspkind'

-- Load plugins settings
require 'samir.autopairs'
require 'samir.barbar'
require 'samir.camelcasemotion'
require 'samir.colorizer'
require 'samir.comment'
require 'samir.compe'
require 'samir.dap'
require 'samir.feline'
require 'samir.gitblame'
require 'samir.gitsigns'
require 'samir.go'
require 'samir.highlightedundo'
require 'samir.illuminate'
require 'samir.indentline'
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
require 'samir.treesitter-textobjects'
require 'samir.trouble'
require 'samir.vimgo'
require 'samir.vista'
require 'samir.vsnip'

-- Vimscript stuff
require 'samir.vimscript'

require('package-info').setup()
