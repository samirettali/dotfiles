require("xeno").setup({
  background = "#1a2332",
  accent = "#4d8fd6",
  properties = {
    contrast = 0.0,
    variation = 0.6,
    chroma = 0.3,
    lightness = -0.1,
  },
  transparent = false,
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "sapphire"
