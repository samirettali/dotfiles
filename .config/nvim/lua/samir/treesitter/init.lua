require('nvim-treesitter.configs').setup {
  ensure_installed = {"typescript", "html", "tsx", "lua", "json", "rust", "css", "javascript"},
  highlight = {
    enable = true,
  },
}
