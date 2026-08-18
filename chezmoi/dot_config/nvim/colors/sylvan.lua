require("xeno").setup({
  background = "#151615",
  accent = "#3b594e",
  properties = {
    contrast = -0.3,
    variation = 0.1,
    chroma = 0.0,
    lightness = 0.0,
  },
  transparent = false,
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "sylvan"
