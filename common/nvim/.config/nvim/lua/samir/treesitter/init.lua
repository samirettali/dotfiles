require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "typescript",
    "html",
    "tsx",
    "lua",
    "json",
    "rust",
    "css",
    "javascript"
  },
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
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}
