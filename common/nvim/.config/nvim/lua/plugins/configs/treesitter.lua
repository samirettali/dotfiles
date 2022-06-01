local present, treesitter = pcall(require, 'nvim-treesitter.configs')

if not present then
    return false
end

local options = {
  ensure_installed = { "lua", "rust", "go" },
  matchup = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  context_commentstring = {
    enable = true
  },
}

treesitter.setup(options)
