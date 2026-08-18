require("xeno").setup({
  background = "#000000",
  accent = "#0d0dc8",
  properties = {
    contrast = 0.1,
    variation = 0.1,
    chroma = 0.1,
    lightness = 0.0,
  },
  transparent = false,
  foreground = "#bbbbbb",
  red = "#bb0000",
  green = "#00bb00",
  yellow = "#bbbb00",
  blue = "#0d0dc8",
  purple = "#bb00bb",
  cyan = "#00bbbb",
  integrations = {
    ghostty = {
      enabled = false,
      update_config = false
    }
  },
})
vim.g.colors_name = "xeno-ghostty-dark"
