require("xeno").setup({
  background = "#1a211d",
  accent = "#8fae7a",
  properties = {
    contrast = -0.1,
    variation = 0.1,
    chroma = -0.1,
    lightness = 0.1,
  },
  transparent = false,
  foreground = "#d8ddd0",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "morning-haze"
