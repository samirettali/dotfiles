return {
    "AlexvZyl/nordic.nvim",
    priority = 1000,
    config = function()
        local nordic = require("nordic")
        local colors = require("nordic.colors")

        local opts = {
            bright_border = true,
            reduced_blue = true,
            override = {
                WinBar = {
                    bg = colors.bg,
                },
                WinBarNC = {
                    bg = colors.bg,
                },
            }
        }

        nordic.setup(opts)
        nordic.load()
    end
}
