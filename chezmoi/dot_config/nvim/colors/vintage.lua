require("xeno").setup({
  background = "#2c2620",
  accent = "#8a7a3f",
  properties = {
    contrast = -0.2,
    variation = 0.1,
    chroma = -0.3,
    lightness = 0.2,
  },
  transparent = false,
  foreground = "#d9cbb3",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "vintage"
