require('nvim-treesitter.configs').setup {
  ensure_installed = 'all',
  matchup = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
  autotag = {
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
