require("xeno").setup({
  background = "#0a141c",
  accent = "#3ddc97",
  properties = {
    contrast = 0.1,
    variation = 0.1,
    chroma = 0.1,
    lightness = -0.1,
  },
  transparent = false,
  foreground = "#c9dde2",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "polarized"
