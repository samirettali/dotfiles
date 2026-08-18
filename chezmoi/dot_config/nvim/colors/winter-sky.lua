require("xeno").setup({
  background = "#161c24",
  accent = "#7ec8d4",
  properties = {
    contrast = -0.1,
    variation = 0.0,
    chroma = -0.1,
    lightness = 0.1,
  },
  transparent = false,
  foreground = "#c8d8e8",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "winter-sky"
