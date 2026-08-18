require("xeno").setup({
  background = "#171a21",
  accent = "#5b7ca8",
  properties = {
    contrast = 0.1,
    variation = 0.1,
    chroma = -0.3,
    lightness = -0.3,
  },
  transparent = false,
  foreground = "#bcc6d4",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "nocturnal"
