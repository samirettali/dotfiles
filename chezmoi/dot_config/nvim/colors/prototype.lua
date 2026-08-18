require("xeno").setup({
  background = "#1a1c1a",
  accent = "#7a9a7d",
  properties = {
    contrast = -0.1,
    variation = 0.1,
    chroma = -0.1,
    lightness = 0.0,
  },
  transparent = false,
  foreground = "#c7ccc7",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "prototype"
