require("xeno").setup({
  background = "#1A120B",
  accent = "#EADBC8",
  properties = {
    contrast = 0.1,
    variation = 0.1,
    chroma = 0.1,
    lightness = 0.0,
  },
  transparent = false,
  foreground = "#F5EFE6",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "latte-express"
