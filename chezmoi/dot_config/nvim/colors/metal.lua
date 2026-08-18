require("xeno").setup({
  background = "#2b2d2e",
  accent = "#c17a3d",
  properties = {
    contrast = -0.1,
    variation = 0.0,
    chroma = -0.1,
    lightness = -0.1,
  },
  transparent = false,
  foreground = "#c6cac7",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "metal"
