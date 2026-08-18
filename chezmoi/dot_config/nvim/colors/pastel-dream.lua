require("xeno").setup({
  background = "#2c2028",
  accent = "#e6a8c8",
  properties = {
    contrast = -0.2,
    variation = 0.1,
    chroma = -0.1,
    lightness = 0.2,
  },
  transparent = false,
  foreground = "#e8dce0",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "pastel-dream"
