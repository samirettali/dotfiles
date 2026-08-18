require("xeno").setup({
  background = "#141f1c",
  accent = "#5cb894",
  properties = {
    contrast = -0.1,
    variation = 0.1,
    chroma = 0.2,
    lightness = 0.1,
  },
  transparent = false,
  foreground = "#c5d9d0",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "stratosphere"
