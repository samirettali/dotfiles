local present, nordic = pcall(require, "nordic")
if not present then
    return
end

local config = {
    bold_keywords = true,
    italic_comments = true,
    transparent_bg = false,
    reduced_blue = true,
    override = {},
    cursorline = {
        bold = false,
        theme = "light",
    },
    noice = {
        style = "flat" -- classic | flat
    },
    telescope = {
        style = "flat", -- classic | flat
    },
}

nordic.setup(config)
nordic.load()
